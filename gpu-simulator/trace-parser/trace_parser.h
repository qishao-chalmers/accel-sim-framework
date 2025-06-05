// developed by Mahmoud Khairy, Purdue Univ

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>
#ifndef TRACE_PARSER_H
#define TRACE_PARSER_H

#define WARP_SIZE 32
#define MAX_DST 1
#define MAX_SRC 4
#define MAX_STORE_DATA_REGS 4  // Maximum number of registers for store data

enum command_type {
  kernel_launch = 1,
  cpu_gpu_mem_copy,
  gpu_cpu_mem_copy,
};

enum address_space { GLOBAL_MEM = 1, SHARED_MEM, LOCAL_MEM, TEX_MEM };

enum address_scope {
  L1_CACHE = 1,
  L2_CACHE,
  SYS_MEM,
};

enum address_format { list_all = 0, base_stride = 1, base_delta = 2 };

// Enum to track the data type of store operations
enum store_data_type_t {
  STORE_DATA_UNKNOWN = 0,
  STORE_DATA_INT8 = 1,
  STORE_DATA_INT16 = 2, 
  STORE_DATA_INT32 = 3,
  STORE_DATA_INT64 = 4,
  STORE_DATA_FLOAT32 = 5,
  STORE_DATA_FLOAT64 = 6
};

// Structure to hold store data information
struct inst_store_data_t {
  bool is_store;                                    // Flag to indicate if this is a store operation
  store_data_type_t data_type;                      // Type of data being stored
  int num_regs;                                     // Number of registers containing store data
  uint64_t data[WARP_SIZE][MAX_STORE_DATA_REGS];    // Store data values [thread][reg_index]
  
  inst_store_data_t();
  ~inst_store_data_t();
};

struct trace_command {
  std::string command_string;
  command_type m_type;
  unsigned trace_id;
};

struct inst_memadd_info_t {
  uint64_t addrs[WARP_SIZE];
  int32_t width;

  void base_stride_decompress(unsigned long long base_address, int stride,
                              const std::bitset<WARP_SIZE> &mask);
  void base_delta_decompress(unsigned long long base_address,
                             const std::vector<long long> &deltas,
                             const std::bitset<WARP_SIZE> &mask);
};

struct inst_trace_t {
  inst_trace_t();
  inst_trace_t(const inst_trace_t &b);

  unsigned line_num;
  unsigned m_pc;
  unsigned mask;
  unsigned reg_dsts_num;
  unsigned reg_dest[MAX_DST];
  std::string opcode;
  unsigned reg_srcs_num;
  unsigned reg_src[MAX_SRC];
  uint64_t imm;

  inst_memadd_info_t *memadd_info;
  inst_store_data_t *store_data_info;  // Store data information

  bool parse_from_string(std::string trace, unsigned tracer_version,
                         unsigned enable_lineinfo);

  bool check_opcode_contain(const std::vector<std::string> &opcode,
                            std::string param) const;

  unsigned get_datawidth_from_opcode(
      const std::vector<std::string> &opcode) const;

  std::vector<std::string> get_opcode_tokens() const;

  ~inst_trace_t();
};

class PipeReader {
 public:
  PipeReader(const std::string &filePath);

  // Destructor to close the pipe
  ~PipeReader() {
    if (pipe) {
      pclose(pipe);  // Close the pipe when done
    }
  }

  // It does not make sense to implement copy semantics for PipeReader,
  // because each instance should hold a unique Linux pipe handle
  PipeReader(const PipeReader &) = delete;
  PipeReader &operator=(const PipeReader &) = delete;

  // Move semantics can be supported
  PipeReader(PipeReader &&) noexcept;
  PipeReader &operator=(PipeReader &&) noexcept;

  // Read one line
  bool readLine(std::string &line);

 private:
  FILE *pipe = NULL;    // Store the pipe
  std::string command;  // Store the shell command to be executed

  // Helper function to check if a string ends with a specific suffix (file
  // extension)
  bool hasEnding(const std::string &fullString, const std::string &ending);

  void OpenFile(const std::string &filePath);
};

struct kernel_trace_t {
  kernel_trace_t(const std::string &filePath);

  std::string kernel_name;
  unsigned kernel_id;
  unsigned grid_dim_x;
  unsigned grid_dim_y;
  unsigned grid_dim_z;
  unsigned tb_dim_x;
  unsigned tb_dim_y;
  unsigned tb_dim_z;
  unsigned shmem;
  unsigned nregs;
  unsigned long long cuda_stream_id;
  unsigned binary_verion;
  unsigned enable_lineinfo;
  unsigned trace_verion;
  std::string nvbit_verion;
  unsigned long long shmem_base_addr;
  unsigned long long local_base_addr;
  PipeReader pipeReader;
};

class trace_parser {
 public:
  trace_parser() {}
  trace_parser(const char *kernellist_filepath);

  std::vector<trace_command> parse_commandlist_file();

  kernel_trace_t *parse_kernel_info(const std::string &kerneltraces_filepath,
                                    bool is_multi_trace = false,
                                    unsigned trace_id = 0);

  void parse_memcpy_info(const std::string &memcpy_command, size_t &add,
                         size_t &count, std::string &dump_filename);

  void get_next_threadblock_traces(
      std::vector<std::vector<inst_trace_t> *> threadblock_traces,
      unsigned trace_version, unsigned enable_lineinfo,
      class PipeReader &pipeReader);

  void kernel_finalizer(kernel_trace_t *trace_info);

  unsigned get_trace_num() {
    return kernellist_filenames.size();
  }

  unsigned get_trace1_kernel_num() {
    return trace1_kernel_num;
  }

  unsigned get_trace2_kernel_num() {
    return trace2_kernel_num;
  }
 private:
  std::vector<std::string> kernellist_filenames;
  unsigned trace1_kernel_num = 0;  // Number of kernels in the first trace
  unsigned trace2_kernel_num = 0;  // Number of kernels in the second trace
};

#endif
