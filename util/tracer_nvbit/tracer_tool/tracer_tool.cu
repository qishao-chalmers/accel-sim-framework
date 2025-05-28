/* Author1: Mahmoud Khairy, abdallm@purdue.com - 2019 */
/* Author2: Jason Shen, shen203@purdue.edu - 2019 */

#include <assert.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

#include <algorithm>
#include <bitset>
#include <iostream>
#include <iterator>
#include <map>
#include <sstream>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <regex>
/* every tool needs to include this once */
#include "nvbit_tool.h"

/* nvbit interface file */
#include "nvbit.h"

/* for channel */
#include "utils/channel.hpp"

/* contains definition of the inst_trace_t structure */
#include "common.h"

#define TRACER_VERSION "5"

/* Channel used to communicate from GPU to CPU receiving thread */
#define CHANNEL_SIZE (1l << 20)
static __managed__ ChannelDev channel_dev;
static ChannelHost channel_host;

/* receiving thread and its control variables */
pthread_t recv_thread;
volatile bool recv_thread_started = false;
volatile bool recv_thread_receiving = false;

/* skip flag used to avoid re-entry on the nvbit_callback when issuing
 * flush_channel kernel call */
bool skip_flag = false;

/* global control variables for this tool */
uint32_t instr_begin_interval = 0;
uint32_t instr_end_interval = UINT32_MAX;
int verbose = 0;
int enable_compress = 1;
int print_core_id = 0;
int exclude_pred_off = 1;
int active_from_start = 1;
int lineinfo = 0;
/* used to select region of interest when active from start is 0 */
bool active_region = true;

/* Should we terminate the program once we are done tracing? */
int terminate_after_limit_number_of_kernels_reached = 0;
int user_defined_folders = 0;

/* Use xz to compress the *.trace file */
int xz_compress_trace = 0;

/* Memory dumping control variables */
int enable_memory_dump = 0;
int memory_dump_compress = 0;

/* opcode to id map and reverse map  */
std::map<std::string, int> opcode_to_id_map;
std::map<int, std::string> id_to_opcode_map;

std::string user_folder = getcwd(NULL, 0);
std::string cwd = getcwd(NULL, 0);
std::string traces_location = cwd + "/traces/";
std::string kernelslist_location = cwd + "/traces/kernelslist";
std::string stats_location = cwd + "/traces/stats.csv";

std::unordered_map<CUcontext, std::string> ctx_kernelslist;
std::unordered_map<CUcontext, std::string> ctx_stats_location;
std::unordered_map<CUcontext, int> ctx_kernelid;
std::unordered_map<CUcontext, FILE *> ctx_resultsFile;
std::unordered_map<CUcontext, int> ctx_memcpy_counter;

std::string kernel_ranges = "";

struct KernelRange {
  uint64_t start;
  uint64_t end; // UINT64_MAX means open-ended
  std::vector<std::regex> kernel_name_regexes;  // Vector of regexes for multiple patterns
};
std::vector<KernelRange> g_kernel_ranges;
uint64_t g_max_kernel_id = 0;
void parse_kernel_ranges_from_env() {
  g_kernel_ranges.clear();
  g_max_kernel_id = 0;

  const char* env_var = std::getenv("DYNAMIC_KERNEL_RANGE");
  if (!env_var || std::string(env_var).empty()) {
      g_kernel_ranges.push_back({0, 0, {std::regex(".*")}});  // 0 end = trace all
      return;
  }
  std::istringstream iss(env_var);
    std::string token;
    while (iss >> token) {
        size_t dash_pos = token.find('-');
        size_t regex_pos = token.find('@');  // kernel name indicated by @
        uint64_t start = 0;
        uint64_t end = 0;

        if (regex_pos != std::string::npos) {
            // Kernel name range with regex
            std::string range_part = token.substr(0, regex_pos);
            std::string regex_str = token.substr(regex_pos + 1);

          

            // Parse the range part for start and end
            size_t dash_pos_range = range_part.find('-');
            if (dash_pos_range != std::string::npos) {
                start = std::stoull(range_part.substr(0, dash_pos_range));
                end = std::stoull(range_part.substr(dash_pos_range + 1));
            } else {
                start = std::stoull(range_part);
                end = start;
            }

            // Split multiple regexes by commas
            std::vector<std::string> regex_strings;
            std::istringstream regex_stream(regex_str);
            std::string regex_token;
            while (std::getline(regex_stream, regex_token, ',')) {
                try {
                    g_kernel_ranges.push_back({start, end, {std::regex(regex_token)}});
                } catch (const std::regex_error& e) {
                    std::cerr << "Invalid regex: " << regex_token << std::endl;
                }
            }
        } else {
            // Normal range without kernel name regex
            size_t dash_pos_range = token.find('-');

            if (dash_pos_range != std::string::npos) {
                start = std::stoull(token.substr(0, dash_pos_range));
                end = std::stoull(token.substr(dash_pos_range + 1));
            } else {
                start = std::stoull(token);
                end = start;
            }

            g_kernel_ranges.push_back({start, end, {std::regex(".*")}});
        }

        // Update max kernel ID if needed
        if (end > g_max_kernel_id) {
            g_max_kernel_id = end;
        }
    }


}

bool should_trace_kernel(uint64_t kernel_id, const std::string& kernel_name) {
  for (const auto& range : g_kernel_ranges) {
    // Check range for kernel ID
    if (range.end == 0) {
        if (kernel_id >= range.start) {
            // Match any of the regexes for this range
            for (const auto& regex : range.kernel_name_regexes) {
                if (std::regex_match(kernel_name, regex)) {
                    return true;
                }
            }
        }
    } else if (kernel_id >= range.start && kernel_id <= range.end) {
        // Match any of the regexes for this range
        for (const auto& regex : range.kernel_name_regexes) {
            if (std::regex_match(kernel_name, regex)) {
                return true;
            }
        }
    }
  }
  return false;
}


enum address_format { list_all = 0, base_stride = 1, base_delta = 2 };

/* File pointers for the kernels, and stats files */
static FILE *kernelsFile = NULL;
static FILE *statsFile = NULL;
static bool first_call = true;

unsigned old_total_insts = 0;
unsigned old_total_reported_insts = 0;

void nvbit_at_init() {
  setenv("CUDA_MANAGED_FORCE_DEVICE_ALLOC", "1", 1);
  GET_VAR_INT(
      instr_begin_interval, "INSTR_BEGIN", 0,
      "Beginning of the instruction interval where to apply instrumentation");
  GET_VAR_INT(instr_end_interval, "INSTR_END", UINT32_MAX,
              "End of the instruction interval where to apply instrumentation");
  GET_VAR_INT(exclude_pred_off, "EXCLUDE_PRED_OFF", 1,
              "Exclude predicated off instruction from count");
  GET_VAR_INT(lineinfo, "TRACE_LINEINFO", 0,
              "Include source code line info at the start of each traced line. "
              "The target binary must be compiled with -lineinfo or "
              "--generate-line-info");
  GET_VAR_STR(kernel_ranges, "DYNAMIC_KERNEL_RANGE",
  "Specify kernel IDs or ranges to trace. Format:\n"
  "  - Single ID:       \"2\" traces only kernel 2.\n"
  "  - Range:           \"5-8\" traces kernels 5 through 8 (inclusive).\n"
  "  - Open-ended:      \"10-\" traces from kernel 10 onward.\n"
  "  - Multiple ranges: \"2 5-8 10-\" (space-separated).\n"
  "  - With regex:      \"5-8@kernel_a.*,kernel_b.*\" traces kernels 5–8 with matching names.\n"
  "If unset or empty, all kernels will be traced from the beginning.");
GET_VAR_INT(
      active_from_start, "ACTIVE_FROM_START", 1,
      "Start instruction tracing from start or wait for cuProfilerStart "
      "and cuProfilerStop. If set to 0, DYNAMIC_KERNEL_RANGE options have no "
      "effect");
  GET_VAR_INT(verbose, "TOOL_VERBOSE", 0, "Enable verbosity inside the tool");
  GET_VAR_INT(enable_compress, "TOOL_COMPRESS", 1, "Enable traces compression");
  GET_VAR_INT(print_core_id, "TOOL_TRACE_CORE", 0,
              "write the core id in the traces");
  GET_VAR_INT(
      terminate_after_limit_number_of_kernels_reached, "TERMINATE_UPON_LIMIT",
      0, "Stop the process once the current kernel > DYNAMIC_KERNEL_LIMIT_END");
  GET_VAR_INT(user_defined_folders, "USER_DEFINED_FOLDERS", 0,
              "Uses the user defined "
              "folder TRACES_FOLDER path environment");
  GET_VAR_INT(xz_compress_trace, "TRACE_FILE_COMPRESS", 1,
              "Create xz-compressed trace"
              "file");
  GET_VAR_INT(enable_memory_dump, "ENABLE_MEMORY_DUMP", 1,
              "Enable memory dump");
  GET_VAR_INT(memory_dump_compress, "MEMORY_DUMP_COMPRESS", 0,
              "Enable memory dump compression");
  std::string pad(100, '-');
  printf("%s\n", pad.c_str());

  
  active_region = false;
  char * usr_defined_folder = std::getenv("TRACES_FOLDER");
  if (usr_defined_folder != NULL)
    user_folder = usr_defined_folder;
  parse_kernel_ranges_from_env();

}

/* Set used to avoid re-instrumenting the same functions multiple times */
std::unordered_set<CUfunction> already_instrumented;

/* instrument each memory instruction adding a call to the above instrumentation
 * function */
void instrument_function_if_needed(CUcontext ctx, CUfunction func) {
  std::vector<CUfunction> related_functions =
      nvbit_get_related_functions(ctx, func);

  /* add kernel itself to the related function vector */
  related_functions.push_back(func);

  /* iterate on function */
  for (auto f : related_functions) {
    /* "recording" function was instrumented, if set insertion failed
     * we have already encountered this function */
    if (!already_instrumented.insert(f).second) {
      continue;
    }

    const std::vector<Instr *> &instrs = nvbit_get_instrs(ctx, f);
    if (verbose) {
      printf("Inspecting function %s at address 0x%lx\n",
             nvbit_get_func_name(ctx, f), nvbit_get_func_addr(ctx,f));
    }

    uint32_t cnt = 0;
    /* iterate on all the static instructions in the function */
    for (auto instr : instrs) {
      uint32_t line_num = 0;
      // Temporary workaround for a bug in NVBit 1.7.4, which does not correctly
      // handle `call.rel`. Instrumenting this instruction leads to illegal
      // memory access. Refer to:
      // https://github.com/NVlabs/NVBit/issues/142#issue-2911561744
      if (!strcmp(instr->getOpcode(), "CALL.REL.NOINC")) {
        printf("Warning: Ignoring CALL.REL.NOINC (NVBit 1.7.4 bug)\n");
        continue;
      }

      if (cnt < instr_begin_interval || cnt >= instr_end_interval) {
        cnt++;
        continue;
      }

      if (verbose) {
        instr->printDecoded();
      }

      if (lineinfo) {
        char *file_name, *dir_name;
        nvbit_get_line_info(ctx, func, instr->getOffset(), &file_name,
                            &dir_name, &line_num);
      }

      if (opcode_to_id_map.find(instr->getOpcode()) == opcode_to_id_map.end()) {
        int opcode_id = opcode_to_id_map.size();
        opcode_to_id_map[instr->getOpcode()] = opcode_id;
        id_to_opcode_map[opcode_id] = instr->getOpcode();
      }

      int opcode_id = opcode_to_id_map[instr->getOpcode()];

      /* check all operands. For now, we ignore constant, TEX, predicates and
       * unified registers. We only report vector regisers */
      int src_oprd[MAX_SRC];
      int srcNum = 0;
      int dst_oprd = -1;
      int mem_oper_idx = -1;
      int num_mref = 0;
      uint64_t imm_value = 0;

      for (int i = 0; i < instr->getNumOperands(); ++i) {
        const InstrType::operand_t *op = instr->getOperand(i);
        if (op->type == InstrType::OperandType::MREF) {
          assert(srcNum < MAX_SRC);
          src_oprd[srcNum] = instr->getOperand(i)->u.mref.ra_num;
          srcNum++;
          mem_oper_idx++;
          num_mref++;
          // if(mem_oper_idx == 0){
          //   mem_oper_idx = 1; // loop control
          // }
        } else if (op->type == InstrType::OperandType::REG) {
          if (i == 0) {
            // find dst reg
            dst_oprd = instr->getOperand(0)->u.reg.num;
          } else {
            // find src regs
            assert(srcNum < MAX_SRC);
            src_oprd[srcNum] = instr->getOperand(i)->u.reg.num;
            srcNum++;
          }
        }
        // Add immediate value for DEPBAR instruction
        else if (op->type == InstrType::OperandType::IMM_UINT64) {
          imm_value = instr->getOperand(i)->u.imm_uint64.value;
        }
      }

      do {
        /* insert call to the instrumentation function with its
         * arguments */
        nvbit_insert_call(instr, "instrument_inst", IPOINT_BEFORE);

        /* pass predicate value */
        nvbit_add_call_arg_guard_pred_val(instr);

        /* send opcode and pc */
        nvbit_add_call_arg_const_val32(instr, opcode_id);
        nvbit_add_call_arg_const_val32(instr, (int)instr->getOffset());

        /* mem addresses info */
        if (mem_oper_idx >= 0) {
          nvbit_add_call_arg_const_val32(instr, 1);
          assert(num_mref <= 2);
          if (num_mref == 2) { // LDGSTS
            nvbit_add_call_arg_mref_addr64(instr, 1 - mem_oper_idx);
          } else {
            nvbit_add_call_arg_mref_addr64(instr, mem_oper_idx);
          }
          nvbit_add_call_arg_const_val32(instr, (int)instr->getSize());
        } else {
          nvbit_add_call_arg_const_val32(instr, 0);
          nvbit_add_call_arg_const_val64(instr, static_cast<uint64_t>(-1));
          nvbit_add_call_arg_const_val32(instr, static_cast<uint32_t>(-1));
        }

        /* reg info */
        nvbit_add_call_arg_const_val32(instr, dst_oprd);
        for (int i = 0; i < srcNum; i++) {
          nvbit_add_call_arg_const_val32(instr, src_oprd[i]);
        }
        for (int i = srcNum; i < MAX_SRC; i++) {
          nvbit_add_call_arg_const_val32(instr, static_cast<uint32_t>(-1));
        }
        nvbit_add_call_arg_const_val32(instr, srcNum);

        /* immediate info */
        nvbit_add_call_arg_const_val64(instr, imm_value);

        /* add pointer to channel_dev and other counters*/
        nvbit_add_call_arg_const_val64(instr, (uint64_t)&channel_dev);
        nvbit_add_call_arg_const_val64(instr,
                                       (uint64_t)&total_dynamic_instr_counter);
        nvbit_add_call_arg_const_val64(
            instr, (uint64_t)&reported_dynamic_instr_counter);
        nvbit_add_call_arg_const_val64(instr, (uint64_t)&stop_report);
        /* Add Source code line number for current instr */
        nvbit_add_call_arg_const_val32(instr, (int)line_num);

        // Detect if this is a store operation and capture store data
        std::string opcode_str = instr->getOpcode();
        bool is_store_op = (opcode_str.find("ST") == 0 || 
                           opcode_str.find("STG") == 0 || 
                           opcode_str.find("STS") == 0 ||
                           opcode_str.find("STL") == 0 ||
                           opcode_str.find("ATOM") == 0 ||
                           opcode_str.find("RED") == 0);
        
        nvbit_add_call_arg_const_val32(instr, is_store_op ? 1 : 0);
        
        // For store operations, identify and capture the data registers
        std::vector<int> store_data_regs;
        store_data_type_t data_type = STORE_DATA_UNKNOWN;
        
        if (is_store_op && mem_oper_idx >= 0) {
          // Determine data type from opcode
          if (opcode_str.find(".F32") != std::string::npos || opcode_str.find(".32") != std::string::npos) {
            data_type = STORE_DATA_FLOAT32;
          } else if (opcode_str.find(".F64") != std::string::npos || opcode_str.find(".64") != std::string::npos) {
            data_type = STORE_DATA_FLOAT64;
          } else if (opcode_str.find(".U64") != std::string::npos || opcode_str.find(".S64") != std::string::npos) {
            data_type = STORE_DATA_INT64;
          } else if (opcode_str.find(".U32") != std::string::npos || opcode_str.find(".S32") != std::string::npos) {
            data_type = STORE_DATA_INT32;
          } else if (opcode_str.find(".U16") != std::string::npos || opcode_str.find(".S16") != std::string::npos) {
            data_type = STORE_DATA_INT16;
          } else if (opcode_str.find(".U8") != std::string::npos || opcode_str.find(".S8") != std::string::npos) {
            data_type = STORE_DATA_INT8;
          } else {
            // Default based on instruction size
            int size = instr->getSize();
            if (size == 8) data_type = STORE_DATA_INT64;
            else if (size == 4) data_type = STORE_DATA_INT32;
            else if (size == 2) data_type = STORE_DATA_INT16;
            else if (size == 1) data_type = STORE_DATA_INT8;
            else data_type = STORE_DATA_INT32; // fallback
          }
          
          // For store operations, the source registers (excluding address register) contain the data
          for (int i = 0; i < instr->getNumOperands(); ++i) {
            const InstrType::operand_t *op = instr->getOperand(i);
            if (op->type == InstrType::OperandType::REG) {
              // Skip the first operand if it's a destination (for atomic operations)
              // For regular stores, all register operands except the address register contain data
              if (i > 0 || (i == 0 && opcode_str.find("ATOM") != 0 && opcode_str.find("RED") != 0)) {
                // Check if this register is not the address register
                bool is_addr_reg = false;
                for (int j = 0; j < instr->getNumOperands(); ++j) {
                  const InstrType::operand_t *addr_op = instr->getOperand(j);
                  if (addr_op->type == InstrType::OperandType::MREF && 
                      addr_op->u.mref.ra_num == op->u.reg.num) {
                    is_addr_reg = true;
                    break;
                  }
                }
                if (!is_addr_reg) {
                  // For 64-bit data types, we need two consecutive registers
                  // For smaller types, we use one register
                  if (data_type == STORE_DATA_FLOAT64 || data_type == STORE_DATA_INT64) {
                    store_data_regs.push_back(op->u.reg.num);     // Lower 32 bits
                    store_data_regs.push_back(op->u.reg.num + 1); // Upper 32 bits
                  } else {
                    store_data_regs.push_back(op->u.reg.num);
                  }
                }
              }
            }
          }
        }
        
        // Add data type
        nvbit_add_call_arg_const_val32(instr, (int32_t)data_type);
        
        // Add number of store data registers
        nvbit_add_call_arg_const_val32(instr, store_data_regs.size());
        
        // Add store data register values based on data type
        for (int reg_num : store_data_regs) {
          // The boolean parameter indicates this is a variadic argument, not the data type
          // nvbit always captures register values as uint32_t regardless of actual content
          nvbit_add_call_arg_reg_val(instr, reg_num, true);  // true = variadic argument
        }

        mem_oper_idx--;
      } while (mem_oper_idx >= 0);

      cnt++;
    }
  }
}

__global__ void flush_channel() {
  /* push memory access with negative cta id to communicate the kernel is
   * completed */
  inst_trace_t ma;
  ma.cta_id_x = -1;
  channel_dev.push(&ma, sizeof(inst_trace_t));

  /* flush channel */
  channel_dev.flush();
}

static void enter_kernel_launch(CUcontext ctx, CUfunction func,
                                nvbit_api_cuda_t cbid, void *params,
                                bool stream_capture = false,
                                bool build_graph = false) {
  // no need to sync during stream capture or manual graph build, since no
  // kernel is actually launched.
  if (!stream_capture && !build_graph) {
    /* Make sure GPU is idle */
    cudaDeviceSynchronize();
    assert(cudaGetLastError() == cudaSuccess);
  }

  // Mark if the kernel should be traced
  std::string func_name = std::string(nvbit_get_func_name(ctx, func, true));
  if (active_from_start && should_trace_kernel(ctx_kernelid[ctx], func_name))
    active_region = true;

  // Terminate tracing if the limit number of kernels is reached
  if (terminate_after_limit_number_of_kernels_reached &&
    g_max_kernel_id != 0 &&
      ctx_kernelid[ctx] > g_max_kernel_id) {
    exit(0);
  }

  // Get launch config for this kernel
  unsigned int gridDimX, gridDimY, gridDimZ;
  unsigned int blockDimX, blockDimY, blockDimZ;
  unsigned int sharedMemBytes;
  CUstream hStream;
  if (cbid == API_CUDA_cuLaunchKernelEx_ptsz ||
      cbid == API_CUDA_cuLaunchKernelEx) {
    cuLaunchKernelEx_params *p = (cuLaunchKernelEx_params *)params;
    gridDimX = p->config->gridDimX;
    gridDimY = p->config->gridDimY;
    gridDimZ = p->config->gridDimZ;
    blockDimX = p->config->blockDimX;
    blockDimY = p->config->blockDimY;
    blockDimZ = p->config->blockDimZ;
    sharedMemBytes = p->config->sharedMemBytes;
    hStream = p->config->hStream;
  } else {
    cuLaunchKernel_params *p = (cuLaunchKernel_params *)params;
    gridDimX = p->gridDimX;
    gridDimY = p->gridDimY;
    gridDimZ = p->gridDimZ;
    blockDimX = p->blockDimX;
    blockDimY = p->blockDimY;
    blockDimZ = p->blockDimZ;
    sharedMemBytes = p->sharedMemBytes;
    hStream = p->hStream;
  }

  // Get the number of registers and shared memory size for the kernel
  int nregs;
  CUDA_SAFECALL(cuFuncGetAttribute(&nregs, CU_FUNC_ATTRIBUTE_NUM_REGS, func));

  int shmem_static_nbytes;
  CUDA_SAFECALL(cuFuncGetAttribute(&shmem_static_nbytes,
                                   CU_FUNC_ATTRIBUTE_SHARED_SIZE_BYTES, func));

  int binary_version;
  CUDA_SAFECALL(cuFuncGetAttribute(&binary_version,
                                   CU_FUNC_ATTRIBUTE_BINARY_VERSION, func));

  // Instrument the kernel if needed
  instrument_function_if_needed(ctx, func);

  // Enable or disable tracing based on the active region
  if (active_region) {
    nvbit_enable_instrumented(ctx, func, true);
    stop_report = false;
  } else {
    nvbit_enable_instrumented(ctx, func, false);
    stop_report = true;
  }

  // Create the trace file per kernel
  char buffer[2048];
  std::string trace_filename = user_folder + "/traces/";
  sprintf(buffer, "%s/kernel-%d-ctx_0x%lx.trace", trace_filename.c_str(),
          ctx_kernelid[ctx], ctx);

  if (!stop_report) {
    if (!xz_compress_trace) {
      ctx_resultsFile[ctx] = fopen(buffer, "w");
      printf("Writing results to %s\n", buffer);
    } else {
      char cmd_buffer[1039];
      sprintf(cmd_buffer, "xz -1 -T0 > %s.xz", buffer);
      ctx_resultsFile[ctx] = popen(cmd_buffer, "w");
      printf("Writing results to %s.xz\n", buffer);
    }

    // Writing header information
    fprintf(ctx_resultsFile[ctx], "-kernel name = %s\n",
            nvbit_get_func_name(ctx, func, true));
    fprintf(ctx_resultsFile[ctx], "-kernel id = %d\n", ctx_kernelid[ctx]);
    fprintf(ctx_resultsFile[ctx], "-grid dim = (%d,%d,%d)\n", gridDimX,
            gridDimY, gridDimZ);
    fprintf(ctx_resultsFile[ctx], "-block dim = (%d,%d,%d)\n", blockDimX,
            blockDimY, blockDimZ);
    fprintf(ctx_resultsFile[ctx], "-shmem = %d\n",
            shmem_static_nbytes + sharedMemBytes);
    fprintf(ctx_resultsFile[ctx], "-nregs = %d\n", nregs);
    fprintf(ctx_resultsFile[ctx], "-binary version = %d\n", binary_version);
    fprintf(ctx_resultsFile[ctx], "-cuda stream id = %lu\n", (uint64_t)hStream);
    fprintf(ctx_resultsFile[ctx], "-shmem base_addr = 0x%016lx\n",
            (uint64_t)nvbit_get_shmem_base_addr(ctx));
    fprintf(ctx_resultsFile[ctx], "-local mem base_addr = 0x%016lx\n",
            (uint64_t)nvbit_get_local_mem_base_addr(ctx));
    fprintf(ctx_resultsFile[ctx], "-nvbit version = %s\n", NVBIT_VERSION);
    fprintf(ctx_resultsFile[ctx], "-accelsim tracer version = %s\n",
            TRACER_VERSION);
    fprintf(ctx_resultsFile[ctx], "-enable lineinfo = %d\n", lineinfo);
    fprintf(ctx_resultsFile[ctx], "\n");

    fprintf(ctx_resultsFile[ctx],
            "#traces format = [line_num] PC mask dest_num [reg_dests] "
            "opcode src_num "
            "[reg_srcs] mem_width [adrrescompress?] [mem_addresses] "
            "immediate [STORE_DATA num_regs [REGx:Ty:value ...]]\n");
    fprintf(ctx_resultsFile[ctx], "\n");
  }

  kernelsFile = fopen(ctx_kernelslist[ctx].c_str(), "a");
  // This will be a relative path to the traces file

  sprintf(buffer, "kernel-%d-ctx_0x%lx.trace%s", ctx_kernelid[ctx], ctx,
          xz_compress_trace ? ".xz" : "");
  if (!stop_report) {
    fprintf(kernelsFile, buffer);
    fprintf(kernelsFile, "\n");
  }
  fclose(kernelsFile);

  statsFile = fopen(ctx_stats_location[ctx].c_str(), "a");
  unsigned blocks = gridDimX * gridDimY * gridDimZ;
  unsigned threads = blockDimX * blockDimY * blockDimZ;

  fprintf(statsFile, "%s, %s, %d, %d, %d, %d, %d, %d, %d, %d, ", buffer,
          nvbit_get_func_name(ctx, func, true), gridDimX, gridDimY, gridDimZ,
          blocks, blockDimX, blockDimY, blockDimZ, threads);

  fclose(statsFile);

  ctx_kernelid[ctx]++;
  recv_thread_receiving = true;
}

static void leave_kernel_launch(CUcontext ctx, CUfunction func) {
  /* make sure current kernel is completed */
  cudaDeviceSynchronize();
  assert(cudaGetLastError() == cudaSuccess);

  /* make sure we prevent re-entry on the nvbit_callback when issuing
   * the flush_channel kernel */
  skip_flag = true;

  /* issue flush of channel so we are sure all the memory accesses
   * have been pushed */
  flush_channel<<<1, 1>>>();
  cudaDeviceSynchronize();
  assert(cudaGetLastError() == cudaSuccess);

  /* unset the skip flag */
  skip_flag = false;

  /* wait here until the receiving thread has not finished with the
   * current kernel */
  while (recv_thread_receiving) {
    pthread_yield();
  }

  unsigned total_insts_per_kernel =
      total_dynamic_instr_counter - old_total_insts;
  old_total_insts = total_dynamic_instr_counter;

  unsigned reported_insts_per_kernel =
      reported_dynamic_instr_counter - old_total_reported_insts;
  old_total_reported_insts = reported_dynamic_instr_counter;

  statsFile = fopen(ctx_stats_location[ctx].c_str(), "a");
  fprintf(statsFile, "%d,%d", total_insts_per_kernel,
          reported_insts_per_kernel);
  fprintf(statsFile, "\n");
  fclose(statsFile);

  if (!stop_report) {
    if (!xz_compress_trace) {
      fclose(ctx_resultsFile[ctx]);
    } else {
      pclose(ctx_resultsFile[ctx]);
    }
  }

  std::string func_name = std::string(nvbit_get_func_name(ctx, func, true));
  if (active_from_start && !should_trace_kernel(ctx_kernelid[ctx], func_name))
    active_region = false;
}

void nvbit_at_cuda_event(CUcontext ctx, int is_exit, nvbit_api_cuda_t cbid,
                         const char *name, void *params, CUresult *pStatus) {
  if (skip_flag)
    return;

  if (first_call == true) {
    first_call = false;
    std::string traces_folder = user_folder + "/traces";
    if (mkdir(traces_folder.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) ==
        -1) {
      if (errno == EEXIST) {
        // alredy exists
      } else {
        // something else
        std::cout << "cannot create folder error:" << strerror(errno)
                  << std::endl;
        return;
      }
    }
    kernelsFile = fopen(ctx_kernelslist[ctx].c_str(), "w");
    statsFile = fopen(ctx_stats_location[ctx].c_str(), "w");
    fprintf(statsFile,
            "kernel id, kernel mangled name, grid_dimX, grid_dimY, grid_dimZ, "
            "#blocks, block_dimX, block_dimY, block_dimZ, #threads, "
            "total_insts, total_reported_insts\n");
    fclose(statsFile);
  }

  switch (cbid) {
  // We start with recording kernel launch events
  // Identify all the possible CUDA launch events without stream
  // parameters, they will not get involved with cuda graph
  case API_CUDA_cuLaunch:
  case API_CUDA_cuLaunchGrid: {
    cuLaunch_params *p = (cuLaunch_params *)params;
    CUfunction func = p->f;
    if (!is_exit) {
      enter_kernel_launch(ctx, func, cbid, params, false, false);
    } else {
      leave_kernel_launch(ctx, func);
    }
  } break;
  // To support kernel launched by cuda graph (in addition to existing kernel
  // launche method), we need to do:
  //
  // 1. instrument kernels at cudaGraphAddKernelNode event. This is for cases
  // that kernels are manually added to a cuda graph.
  // 2. distinguish captured kernels when kernels are recorded to a graph
  // using stream capture. cudaStreamIsCapturing() tells us whether a stream
  // is capturiong.
  // 3. per-kernel instruction counters, since cuda graph can launch multiple
  // kernels at the same time.
  //
  // Three cases:
  //
  // 1. original kernel launch:
  //     1a. for any kernel launch without using a stream, we instrument it
  //     before it is launched, call cudaDeviceSynchronize after it is
  //     launched and read the instruction counter of the kernel.
  //     1b. for any kernel launch using a stream, but the stream is not
  //     capturing, we do the same thing as 1a.
  //
  //  2. cuda graph using stream capturing: if a kernel is launched in a
  //  stream and the stream is capturing. We instrument the kernel before it
  //  is launched and do nothing after it is launched, because the kernel is
  //  not running until cudaGraphLaunch. Instead, we issue a
  //  cudaStreamSynchronize after cudaGraphLaunch is done and reset the
  //  instruction counters, since a cloned graph might be launched afterwards.
  //
  //  3. cuda graph manual: we instrument the kernel added by
  //  cudaGraphAddKernelNode and do the same thing for cudaGraphLaunch as 2.
  //
  // The above method should handle most of cuda graph launch cases.
  // kernel launches with stream parameter, they can be used for cuda graph
  case API_CUDA_cuLaunchKernel_ptsz:
  case API_CUDA_cuLaunchKernel:
  case API_CUDA_cuLaunchCooperativeKernel:
  case API_CUDA_cuLaunchCooperativeKernel_ptsz:
  case API_CUDA_cuLaunchKernelEx:
  case API_CUDA_cuLaunchKernelEx_ptsz:
  case API_CUDA_cuLaunchGridAsync: {
    CUfunction func;
    CUstream hStream;

    if (cbid == API_CUDA_cuLaunchKernelEx_ptsz ||
        cbid == API_CUDA_cuLaunchKernelEx) {
      cuLaunchKernelEx_params *p = (cuLaunchKernelEx_params *)params;
      func = p->f;
      hStream = p->config->hStream;
    } else if (cbid == API_CUDA_cuLaunchKernel_ptsz ||
               cbid == API_CUDA_cuLaunchKernel ||
               cbid == API_CUDA_cuLaunchCooperativeKernel_ptsz ||
               cbid == API_CUDA_cuLaunchCooperativeKernel) {
      cuLaunchKernel_params *p = (cuLaunchKernel_params *)params;
      func = p->f;
      hStream = p->hStream;
    } else {
      cuLaunchGridAsync_params *p = (cuLaunchGridAsync_params *)params;
      func = p->f;
      hStream = p->hStream;
    }

    cudaStreamCaptureStatus streamStatus;
    /* check if the stream is capturing, if yes, do not sync */
    CUDA_SAFECALL(cudaStreamIsCapturing(hStream, &streamStatus));
    if (!is_exit) {
      bool stream_capture = (streamStatus == cudaStreamCaptureStatusActive);
      enter_kernel_launch(ctx, func, cbid, params, stream_capture);
    } else {
      if (streamStatus != cudaStreamCaptureStatusActive) {
        if (verbose >= 1) {
          printf("kernel %s not captured by cuda graph\n",
                 nvbit_get_func_name(ctx, func));
        }
        leave_kernel_launch(ctx, func);
      } else {
        if (verbose >= 1) {
          printf("kernel %s captured by cuda graph\n",
                 nvbit_get_func_name(ctx, func));
        }
      }
    }
  } break;
  case API_CUDA_cuGraphAddKernelNode: {
    cuGraphAddKernelNode_params *p = (cuGraphAddKernelNode_params *)params;
    CUfunction func = p->nodeParams->func;

    if (!is_exit) {
      // cuGraphAddKernelNode_params->nodeParams is the same as
      // cuLaunchKernel_params up to sharedMemBytes
      enter_kernel_launch(ctx, func, cbid, (void *)p->nodeParams, false, true);
    }
  } break;
  case API_CUDA_cuGraphLaunch: {
    // if we are exiting a cuda graph launch:
    // Wait until the graph is completed using
    // cudaStreamSynchronize()
    if (is_exit) {
      cuGraphLaunch_params *p = (cuGraphLaunch_params *)params;

      CUDA_SAFECALL(cudaStreamSynchronize(p->hStream));
      assert(cudaGetLastError() == cudaSuccess);
      /* push a flush channel kernel */
      flush_channel<<<1, 1, 0, p->hStream>>>();
      CUDA_SAFECALL(cudaStreamSynchronize(p->hStream));
      assert(cudaGetLastError() == cudaSuccess);
    }

  } break;
  // Now we need to record cuda memcpy events
  case API_CUDA_cuMemcpyHtoD_v2: {
    if (!is_exit) {
      cuMemcpyHtoD_v2_params *p = (cuMemcpyHtoD_v2_params *)params;
      char buffer[1024];
      
      // Generate memory dump filename if enabled
      std::string memory_dump_filename = "";
      if (enable_memory_dump) {
        sprintf(buffer, "memcpy_htod_%d_ctx_0x%lx_addr_0x%016llx_size_%llu.bin", 
                ctx_memcpy_counter[ctx], ctx, p->dstDevice, p->ByteCount);
        memory_dump_filename = user_folder + "/traces/" + buffer;
        
        // Dump the host memory data to binary file
        FILE *dump_file = NULL;
        if (memory_dump_compress) {
          char cmd_buffer[2048];
          sprintf(cmd_buffer, "xz -1 -T0 > %s.xz", memory_dump_filename.c_str());
          dump_file = popen(cmd_buffer, "wb");
          if (verbose) {
            printf("Dumping compressed memory to %s.xz (size: %llu bytes)\n", 
                   memory_dump_filename.c_str(), p->ByteCount);
          }
        } else {
          dump_file = fopen(memory_dump_filename.c_str(), "wb");
          if (verbose) {
            printf("Dumping memory to %s (size: %llu bytes)\n", 
                   memory_dump_filename.c_str(), p->ByteCount);
          }
        }
        
        if (dump_file != NULL) {
          // Write the host memory data to the dump file
          size_t written = fwrite(p->srcHost, 1, p->ByteCount, dump_file);
          if (written != p->ByteCount) {
            printf("Warning: Only wrote %zu out of %llu bytes to memory dump file\n", 
                   written, p->ByteCount);
          }
          
          if (memory_dump_compress) {
            pclose(dump_file);
          } else {
            fclose(dump_file);
          }
        } else {
          printf("Error: Failed to create memory dump file %s\n", memory_dump_filename.c_str());
        }
      }
      
      // Write to kernelslist
      kernelsFile = fopen(ctx_kernelslist[ctx].c_str(), "a");
      if (enable_memory_dump) {
        // Include memory dump filename in kernelslist entry
        sprintf(buffer, "MemcpyHtoD,0x%016llx,%llu,%s%s", 
                p->dstDevice, p->ByteCount, 
                memory_dump_filename.substr(memory_dump_filename.find_last_of('/') + 1).c_str(),
                memory_dump_compress ? ".xz" : "");
      } else {
        // Original format without memory dump
        sprintf(buffer, "MemcpyHtoD,0x%016llx,%llu", p->dstDevice, p->ByteCount);
      }
      fprintf(kernelsFile, buffer);
      fprintf(kernelsFile, "\n");
      fclose(kernelsFile);
      
      // Increment memory copy counter
      ctx_memcpy_counter[ctx]++;
    }
  } break;
  // For cuProfiler, we need to set the active region accordingly
  case API_CUDA_cuProfilerStart: {
    if (is_exit && !active_from_start) {
      active_region = true;
    }
  } break;
  case API_CUDA_cuProfilerStop: {
    if (is_exit && !active_from_start) {
      active_region = false;
    }
  } break;
  default:
    break;
  }
}

bool is_number(const std::string &s) {
  std::string::const_iterator it = s.begin();
  while (it != s.end() && std::isdigit(*it))
    ++it;
  return !s.empty() && it == s.end();
}

unsigned get_datawidth_from_opcode(const std::vector<std::string> &opcode) {
  for (unsigned i = 0; i < opcode.size(); ++i) {
    if (is_number(opcode[i])) {
      return (std::stoi(opcode[i], NULL) / 8);
    } else if (opcode[i][0] == 'U' && is_number(opcode[i].substr(1))) {
      // handle the U* case
      unsigned bits;
      sscanf(opcode[i].c_str(), "U%u", &bits);
      return bits / 8;
    }
  }

  return 4; // default is 4 bytes
}

bool check_opcode_contain(const std::vector<std::string> &opcode,
                          std::string param) {
  for (unsigned i = 0; i < opcode.size(); ++i)
    if (opcode[i] == param)
      return true;

  return false;
}

bool base_stride_compress(const uint64_t *addrs, const std::bitset<32> &mask,
                          uint64_t &base_addr, int &stride) {
  // calulcate the difference between addresses
  // write cosnsctive addresses with constant stride in a more
  // compressed way (i.e. start adress and stride)
  bool const_stride = true;
  bool first_bit1_found = false;
  bool last_bit1_found = false;

  for (int s = 0; s < 32; s++) {
    if (mask.test(s) && !first_bit1_found) {
      first_bit1_found = true;
      base_addr = addrs[s];
      if (s < 31 && mask.test(s + 1))
        stride = addrs[s + 1] - addrs[s];
      else {
        const_stride = false;
        break;
      }
    } else if (first_bit1_found && !last_bit1_found) {
      if (mask.test(s)) {
        if (stride != addrs[s] - addrs[s - 1]) {
          const_stride = false;
          break;
        }
      } else
        last_bit1_found = true;
    } else if (last_bit1_found) {
      if (mask.test(s)) {
        const_stride = false;
        break;
      }
    }
  }

  return const_stride;
}

void base_delta_compress(const uint64_t *addrs, const std::bitset<32> &mask,
                         uint64_t &base_addr, std::vector<long long> &deltas) {
  // save the delta from the previous address
  bool first_bit1_found = false;
  uint64_t last_address = 0;
  for (int s = 0; s < 32; s++) {
    if (mask.test(s) && !first_bit1_found) {
      base_addr = addrs[s];
      first_bit1_found = true;
      last_address = addrs[s];
    } else if (mask.test(s) && first_bit1_found) {
      deltas.push_back(addrs[s] - last_address);
      last_address = addrs[s];
    }
  }
}

void *recv_thread_fun(void *args) {
  CUcontext ctx = (CUcontext)args;
  char *recv_buffer = (char *)malloc(CHANNEL_SIZE);
  while (recv_thread_started) {
    uint32_t num_recv_bytes = 0;
    if (recv_thread_receiving &&
        (num_recv_bytes = channel_host.recv(recv_buffer, CHANNEL_SIZE)) > 0) {
      uint32_t num_processed_bytes = 0;
      while (num_processed_bytes < num_recv_bytes) {
        inst_trace_t *ma = (inst_trace_t *)&recv_buffer[num_processed_bytes];

        /* when we get this cta_id_x it means the kernel has completed
         */
        if (ma->cta_id_x == -1) {
          recv_thread_receiving = false;
          break;
        }

        fprintf(ctx_resultsFile[ctx], "%d ", ma->cta_id_x);
        fprintf(ctx_resultsFile[ctx], "%d ", ma->cta_id_y);
        fprintf(ctx_resultsFile[ctx], "%d ", ma->cta_id_z);
        fprintf(ctx_resultsFile[ctx], "%d ", ma->warpid_tb);
        if (print_core_id) {
          fprintf(ctx_resultsFile[ctx], "%d ", ma->sm_id);
          fprintf(ctx_resultsFile[ctx], "%d ", ma->warpid_sm);
        }
        if (lineinfo) {
          fprintf(ctx_resultsFile[ctx], "%d ", ma->line_num);
        }
        fprintf(ctx_resultsFile[ctx], "%04x ", ma->vpc); // Print the virtual PC
        fprintf(ctx_resultsFile[ctx], "%08x ",
                ma->active_mask & ma->predicate_mask);
        if (ma->GPRDst >= 0) {
          fprintf(ctx_resultsFile[ctx], "1 ");
          fprintf(ctx_resultsFile[ctx], "R%d ", ma->GPRDst);
        } else
          fprintf(ctx_resultsFile[ctx], "0 ");

        // Print the opcode.
        fprintf(ctx_resultsFile[ctx], "%s ",
                id_to_opcode_map[ma->opcode_id].c_str());
        unsigned src_count = 0;
        for (int s = 0; s < MAX_SRC; s++) // GPR srcs count.
          if (ma->GPRSrcs[s] >= 0)
            src_count++;
        fprintf(ctx_resultsFile[ctx], "%d ", src_count);

        for (int s = 0; s < MAX_SRC; s++) // GPR srcs.
          if (ma->GPRSrcs[s] >= 0)
            fprintf(ctx_resultsFile[ctx], "R%d ", ma->GPRSrcs[s]);

        // print addresses
        std::bitset<32> mask(ma->active_mask & ma->predicate_mask);
        if (ma->is_mem) {
          std::istringstream iss(id_to_opcode_map[ma->opcode_id]);
          std::vector<std::string> tokens;
          std::string token;
          while (std::getline(iss, token, '.')) {
            if (!token.empty())
              tokens.push_back(token);
          }
          fprintf(ctx_resultsFile[ctx], "%d ",
                  get_datawidth_from_opcode(tokens));

          bool base_stride_success = false;
          uint64_t base_addr = 0;
          int stride = 0;
          std::vector<long long> deltas;

          if (enable_compress) {
            // try base+stride format
            base_stride_success =
                base_stride_compress(ma->addrs, mask, base_addr, stride);
            if (!base_stride_success) {
              // if base+stride fails, try base+delta format
              base_delta_compress(ma->addrs, mask, base_addr, deltas);
            }
          }

          if (base_stride_success && enable_compress) {
            // base + stride format
            fprintf(ctx_resultsFile[ctx], "%u 0x%llx %d ",
                    address_format::base_stride, base_addr, stride);
          } else if (!base_stride_success && enable_compress) {
            // base + delta format
            fprintf(ctx_resultsFile[ctx], "%u 0x%llx ",
                    address_format::base_delta, base_addr);
            for (int s = 0; s < deltas.size(); s++) {
              fprintf(ctx_resultsFile[ctx], "%lld ", deltas[s]);
            }
          } else {
            // list all the addresses
            fprintf(ctx_resultsFile[ctx], "%u ", address_format::list_all);
            for (int s = 0; s < 32; s++) {
              if (mask.test(s))
                fprintf(ctx_resultsFile[ctx], "0x%016lx ", ma->addrs[s]);
            }
          }
        } else {
          fprintf(ctx_resultsFile[ctx], "0 ");
        }

        // Print the immediate
        fprintf(ctx_resultsFile[ctx], "%d ", ma->imm);

        // Print store data if this is a store operation
        if (ma->is_store && ma->num_store_data_regs > 0) {
          const char* type_names[] = {"UNK", "I8", "I16", "I32", "I64", "F32", "F64"};
          fprintf(ctx_resultsFile[ctx], "STORE_DATA %s %d ", 
                  type_names[ma->store_data_type], ma->num_store_data_regs);
          
          for (int reg_idx = 0; reg_idx < ma->num_store_data_regs; reg_idx++) {
            fprintf(ctx_resultsFile[ctx], "REG%d:", reg_idx);
            for (int tid = 0; tid < 32; tid++) {
              if (mask.test(tid)) {
                // Format output based on data type
                switch (ma->store_data_type) {
                  case STORE_DATA_FLOAT32: {
                    uint32_t int_val = (uint32_t)ma->store_data[tid][reg_idx];
                    float float_val = *(float*)&int_val;
                    fprintf(ctx_resultsFile[ctx], "T%d:%g ", tid, float_val);
                    break;
                  }
                  case STORE_DATA_FLOAT64: {
                    uint64_t int_val = ma->store_data[tid][reg_idx];
                    double double_val = *(double*)&int_val;
                    fprintf(ctx_resultsFile[ctx], "T%d:%g ", tid, double_val);
                    break;
                  }
                  case STORE_DATA_INT64:
                    fprintf(ctx_resultsFile[ctx], "T%d:0x%016llx ", tid, ma->store_data[tid][reg_idx]);
                    break;
                  case STORE_DATA_INT32:
                    fprintf(ctx_resultsFile[ctx], "T%d:0x%08x ", tid, (uint32_t)ma->store_data[tid][reg_idx]);
                    break;
                  case STORE_DATA_INT16:
                    fprintf(ctx_resultsFile[ctx], "T%d:0x%04x ", tid, (uint16_t)ma->store_data[tid][reg_idx]);
                    break;
                  case STORE_DATA_INT8:
                    fprintf(ctx_resultsFile[ctx], "T%d:0x%02x ", tid, (uint8_t)ma->store_data[tid][reg_idx]);
                    break;
                  default:
                    fprintf(ctx_resultsFile[ctx], "T%d:0x%016llx ", tid, ma->store_data[tid][reg_idx]);
                    break;
                }
              }
            }
            fprintf(ctx_resultsFile[ctx], " ");
          }
        }

        fprintf(ctx_resultsFile[ctx], "\n");

        num_processed_bytes += sizeof(inst_trace_t);
      }
    }
  }
  free(recv_buffer);
  return NULL;
}

void nvbit_tool_init(CUcontext ctx) {
  recv_thread_started = true;
  channel_host.init(0, CHANNEL_SIZE, &channel_dev, NULL);
  pthread_create(&recv_thread, NULL, recv_thread_fun, ctx);
}

void nvbit_at_ctx_term(CUcontext ctx) {
  if (recv_thread_started) {
    recv_thread_started = false;
    pthread_join(recv_thread, NULL);
  }
}

void nvbit_at_ctx_init(CUcontext ctx) {
  // Everytime we init a context, add the foldername and kernelid to the set
  char buffer[2048];
  sprintf(buffer, "kernelslist_ctx_0x%lx", ctx);
  std::string tmp_kernelslist = user_folder + "/traces/" + buffer;
  ctx_kernelslist[ctx] = tmp_kernelslist;
  sprintf(buffer, "stats_ctx_0x%lx", ctx);
  std::string tmp_stats = user_folder + "/traces/" + buffer;
  ctx_stats_location[ctx] = tmp_stats;
  ctx_kernelid[ctx] = 1;
  ctx_memcpy_counter[ctx] = 0;
}