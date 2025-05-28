/* Author1: Mahmoud Khairy, abdallm@purdue.com - 2019 */
/* Author2: Jason Shen, shen203@purdue.edu - 2019 */

#include <stdint.h>

static __managed__ uint64_t total_dynamic_instr_counter = 0;
static __managed__ uint64_t reported_dynamic_instr_counter = 0;
static __managed__ bool stop_report = false;

/* information collected in the instrumentation function and passed
 * on the channel from the GPU to the CPU */
#define MAX_SRC 5
#define MAX_STORE_DATA_REGS 4  // Maximum number of registers for store data

// Enum to track the data type of store operations
typedef enum {
  STORE_DATA_UNKNOWN = 0,
  STORE_DATA_INT8 = 1,
  STORE_DATA_INT16 = 2, 
  STORE_DATA_INT32 = 3,
  STORE_DATA_INT64 = 4,
  STORE_DATA_FLOAT32 = 5,
  STORE_DATA_FLOAT64 = 6
} store_data_type_t;

typedef struct {
  int cta_id_x;
  int cta_id_y;
  int cta_id_z;
  int warpid_tb;
  int warpid_sm;
  int sm_id;
  int opcode_id;
  uint64_t addrs[32];
  uint32_t line_num;
  uint32_t vpc;
  bool is_mem;
  int32_t GPRDst;
  int32_t GPRSrcs[MAX_SRC];
  int32_t numSrcs;
  int32_t width;
  uint32_t active_mask;
  uint32_t predicate_mask;
  uint64_t imm;
  // New fields for store data capture
  bool is_store;                                    // Flag to indicate if this is a store operation
  int32_t num_store_data_regs;                     // Number of registers containing store data
  store_data_type_t store_data_type;               // Type of data being stored
  uint64_t store_data[32][MAX_STORE_DATA_REGS];    // Store data values [thread][reg_index] - now 64-bit to handle all types
} inst_trace_t;
