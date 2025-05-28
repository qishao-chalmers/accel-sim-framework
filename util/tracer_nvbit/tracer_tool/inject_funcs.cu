/* Author1: Mahmoud Khairy, abdallm@purdue.com - 2019 */
/* Author2: Jason Shen, shen203@purdue.edu - 2019 */

#include <stdint.h>
#include <stdio.h>

#include <cstdarg>

#include "utils/utils.h"

/* for channel */
#include "utils/channel.hpp"

/* contains definition of the inst_trace_t structure */
#include "common.h"

/* Instrumentation function that we want to inject, please note the use of
 *  extern "C" __device__ __noinline__
 *    To prevent "dead"-code elimination by the compiler.
 */
extern "C" __device__ __noinline__ void
instrument_inst(int pred, int opcode_id, int32_t vpc, bool is_mem,
                uint64_t addr, int32_t width, int32_t desReg, int32_t srcReg1,
                int32_t srcReg2, int32_t srcReg3, int32_t srcReg4,
                int32_t srcReg5, int32_t srcNum, uint64_t immediate,
                uint64_t pchannel_dev, uint64_t ptotal_dynamic_instr_counter,
                uint64_t preported_dynamic_instr_counter, uint64_t pstop_report,
                uint32_t line_num, bool is_store, int32_t store_data_type, 
                int32_t num_store_data_regs, ...) {
  const int active_mask = __ballot_sync(__activemask(), 1);
  const int predicate_mask = __ballot_sync(__activemask(), pred);
  const int laneid = get_laneid();
  const int first_laneid = __ffs(active_mask) - 1;

  if ((*((bool *)pstop_report))) {
    if (first_laneid == laneid) {
      atomicAdd((unsigned long long *)ptotal_dynamic_instr_counter, 1);
      return;
    }
  }

  inst_trace_t ma;

  if (is_mem) {
    /* collect memory address information */
    for (int i = 0; i < 32; i++) {
      ma.addrs[i] = __shfl_sync(active_mask, addr, i);
    }
    ma.width = width;
    ma.is_mem = true;
  } else {
    ma.is_mem = false;
  }

  // Initialize store data fields
  ma.is_store = is_store;
  ma.store_data_type = (store_data_type_t)store_data_type;
  ma.num_store_data_regs = num_store_data_regs;
  
  // Capture store data if this is a store operation
  if (is_store && num_store_data_regs > 0) {
    va_list vl;
    va_start(vl, num_store_data_regs);
    
    for (int reg_idx = 0; reg_idx < num_store_data_regs && reg_idx < MAX_STORE_DATA_REGS; reg_idx++) {
      // nvbit always provides register values as uint32_t
      // We need to interpret them based on the data type
      uint32_t raw_reg_val = va_arg(vl, uint32_t);
      uint64_t store_val = 0;
      
      // Handle different data types appropriately
      switch (ma.store_data_type) {
        case STORE_DATA_FLOAT32: {
          // For float32, the uint32_t contains the correct bit pattern
          store_val = raw_reg_val;
          break;
        }
        case STORE_DATA_FLOAT64: {
          // For float64, we need two consecutive 32-bit registers
          // This is the first register (lower 32 bits)
          store_val = raw_reg_val;
          if (reg_idx + 1 < num_store_data_regs) {
            // Get the next register for upper 32 bits
            uint32_t upper_reg_val = va_arg(vl, uint32_t);
            store_val |= ((uint64_t)upper_reg_val << 32);
            reg_idx++; // Skip the next iteration since we consumed two registers
          }
          break;
        }
        case STORE_DATA_INT64: {
          // For int64, we need two consecutive 32-bit registers
          store_val = raw_reg_val;
          if (reg_idx + 1 < num_store_data_regs) {
            uint32_t upper_reg_val = va_arg(vl, uint32_t);
            store_val |= ((uint64_t)upper_reg_val << 32);
            reg_idx++; // Skip the next iteration
          }
          break;
        }
        case STORE_DATA_INT32:
        case STORE_DATA_INT16:
        case STORE_DATA_INT8:
        default: {
          // For smaller integer types, just use the lower bits
          store_val = raw_reg_val;
          break;
        }
      }
      
      // Collect store data values from all threads in the warp
      for (int tid = 0; tid < 32; tid++) {
        ma.store_data[tid][reg_idx] = __shfl_sync(active_mask, store_val, tid);
      }
    }
    va_end(vl);
  } else {
    // Initialize store data to zero if not a store operation
    for (int tid = 0; tid < 32; tid++) {
      for (int reg_idx = 0; reg_idx < MAX_STORE_DATA_REGS; reg_idx++) {
        ma.store_data[tid][reg_idx] = 0;
      }
    }
  }

  int4 cta = get_ctaid();
  int uniqe_threadId = threadIdx.z * blockDim.y * blockDim.x +
                       threadIdx.y * blockDim.x + threadIdx.x;
  ma.line_num = line_num;
  ma.warpid_tb = uniqe_threadId / 32;

  ma.cta_id_x = cta.x;
  ma.cta_id_y = cta.y;
  ma.cta_id_z = cta.z;
  ma.warpid_sm = get_warpid();
  ma.opcode_id = opcode_id;
  ma.vpc = vpc;
  ma.GPRDst = desReg;
  ma.GPRSrcs[0] = srcReg1;
  ma.GPRSrcs[1] = srcReg2;
  ma.GPRSrcs[2] = srcReg3;
  ma.GPRSrcs[3] = srcReg4;
  ma.GPRSrcs[4] = srcReg5;
  ma.numSrcs = srcNum;
  ma.imm = immediate;
  ma.active_mask = active_mask;
  ma.predicate_mask = predicate_mask;
  ma.sm_id = get_smid();

  /* first active lane pushes information on the channel */
  if (first_laneid == laneid) {
    ChannelDev *channel_dev = (ChannelDev *)pchannel_dev;
    channel_dev->push(&ma, sizeof(inst_trace_t));
    atomicAdd((unsigned long long *)ptotal_dynamic_instr_counter, 1);
    atomicAdd((unsigned long long *)preported_dynamic_instr_counter, 1);
  }
}
