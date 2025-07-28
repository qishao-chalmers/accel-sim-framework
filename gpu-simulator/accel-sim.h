#include <math.h>
#include <stdio.h>
#include <time.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <map>

#include "../ISA_Def/trace_opcode.h"
#include "../trace-parser/trace_parser.h"
#include "abstract_hardware_model.h"
#include "cuda-sim/cuda-sim.h"
#include "gpgpu-sim/gpu-sim.h"
#include "gpgpu-sim/icnt_wrapper.h"
#include "gpgpu_context.h"
#include "gpgpusim_entrypoint.h"
#include "option_parser.h"
#include "trace_driven.h"

extern unsigned stream_num;
extern std::vector<trace_kernel_info_t *> kernels_info;

class accel_sim_framework {
 public:
  accel_sim_framework(int argc, const char **argv);
  accel_sim_framework(std::string config_file, std::string trace_file);

  void init();
  
  void simulation_loop();
  void parse_commandlist();
  void cleanup(unsigned finished_kernel);
  unsigned simulate();
  void global_stream_analysis();  // Global stream analysis function

  void store_original_commands_by_stream();  // Store original commands for each stream
  void restart_completed_stream(unsigned long long stream_id);  // Restart a completed stream
  void check_and_restart_for_min_simulation_time();  // Check minimum simulation time and restart if needed
  trace_kernel_info_t *create_kernel_info(kernel_trace_t *kernel_trace_info,
                                          gpgpu_context *m_gpgpu_context,
                                          trace_config *config,
                                          trace_parser *parser);
  gpgpu_sim *gpgpu_trace_sim_init_perf_model(int argc, const char *argv[],
                                  gpgpu_context *m_gpgpu_context,
                                  trace_config *m_config);


 private:
  gpgpu_context *m_gpgpu_context;
  trace_config tconfig;
  trace_parser tracer;
  gpgpu_sim *m_gpgpu_sim;

  bool concurrent_kernel_sm;
  bool active;
  bool sim_cycles;
  unsigned window_size;
  unsigned commandlist_index;

  bool is_multi_trace;
  unsigned trace1_kernel_num;
  unsigned trace2_kernel_num;

  std::vector<unsigned long long> busy_streams;

  // counts the number of kernels launched in the stream
  std::map<unsigned int, unsigned int> stream_kernel_map;
  std::vector<trace_command> commandlist;
  
  // Global stream analysis data
  std::map<unsigned long long, std::pair<unsigned, unsigned>> global_stream_core_ranges;
  std::map<unsigned long long, std::set<unsigned>> global_stream_core_ranges_set;

  // Stream repetition and completion tracking
  std::map<unsigned long long, bool> stream_completed;  // Track if a stream has completed its original workload
  std::map<unsigned long long, unsigned> stream_repetition_count;  // Track how many times each stream has been repeated
  std::map<unsigned long long, std::vector<trace_command>> stream_original_commands;  // Store original commands for each stream
  std::set<unsigned long long> stream_completed_set;  // Track if a stream has completed its original workload
  unsigned pending_stream_count = 0;  // Count of streams that have been launched but not completed yet
  unsigned max_repetitions;  // Maximum number of repetitions allowed (0 = no repetition)
  bool enable_stream_repetition;  // Flag to enable/disable stream repetition

  // Minimum simulation time configuration (for two-stream mode)
  unsigned long long min_simulation_cycles;  // Minimum simulation cycles required
  bool enable_min_simulation_time;  // Flag to enable/disable minimum simulation time
  unsigned long long simulation_start_cycle;  // Track when simulation started
  bool both_streams_completed_early;  // Track if both streams completed before minimum time

};