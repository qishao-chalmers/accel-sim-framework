#include "accel-sim.h"
#include "accelsim_version.h"

unsigned stream_num = 1;

std::vector<trace_kernel_info_t *> kernels_info;

accel_sim_framework::accel_sim_framework(std::string config_file,
                                          std::string trace_file) {
  std::cout << "Accel-Sim [build " << g_accelsim_version << "]";
  m_gpgpu_context = new gpgpu_context();

  // mimic argv
  unsigned argc = 5;
  const char *argv[] = {"accel-sim.out", "-config", config_file.c_str(),
                        "-trace", trace_file.c_str()};

  gpgpu_sim *m_gpgpu_sim =
      gpgpu_trace_sim_init_perf_model(argc, argv, m_gpgpu_context, &tconfig);
  m_gpgpu_sim->init();

  tracer = trace_parser(tconfig.get_traces_filename());

  tconfig.parse_config();

  init();
}

accel_sim_framework::accel_sim_framework(int argc, const char **argv) {
  std::cout << "Accel-Sim [build " << g_accelsim_version << "]";
  m_gpgpu_context = new gpgpu_context();

  m_gpgpu_sim =
      gpgpu_trace_sim_init_perf_model(argc, argv, m_gpgpu_context, &tconfig);
  m_gpgpu_sim->init();

  tracer = trace_parser(tconfig.get_traces_filename());

  tconfig.parse_config();

  init();
}

void accel_sim_framework::simulation_loop() {
  // for each kernel
  // load file
  // parse and create kernel info
  // launch
  // while loop till the end of the end kernel execution
  // prints stats

  // Record simulation start time for minimum simulation time tracking
  if (enable_min_simulation_time && global_unique_streams.size() == 2) {
    simulation_start_cycle = m_gpgpu_sim->gpu_sim_cycle;
    std::cout << "=== MINIMUM SIMULATION TIME ENABLED ===" << std::endl;
    std::cout << "Minimum simulation cycles: " << min_simulation_cycles << std::endl;
    std::cout << "Simulation started at cycle: " << simulation_start_cycle << std::endl;
  }

  while (commandlist_index < commandlist.size() || !kernels_info.empty()) {
    parse_commandlist();

    // Launch all kernels within window that are on a stream that isn't already
    // running
    std::cout << "=== Stream State Check ===" << std::endl;
    std::cout << "Active kernels in window: " << kernels_info.size() << std::endl;
    std::cout << "Busy streams: ";
    for (auto s : busy_streams) {
      std::cout << s << " ";
    }
    std::cout << std::endl;
    
    // Use pre-calculated global stream core ranges
    bool enable_stream_partitioning = (global_unique_streams.size() > 1);
    if (enable_stream_partitioning) {
      std::cout << "USING GLOBAL STREAM PARTITIONING: " << global_unique_streams.size() 
                << " streams detected globally" << std::endl;
    }

    if (is_policy_change && !is_policy_change_done) {
      is_policy_change_done = true;
      // update the kernel core range
      for (auto& kernel : kernels_info) {
        if (kernel!=nullptr) {
          unsigned streamID = kernel->get_cuda_stream_id();
          auto core_range = global_dynamic_core_ranges[streamID];
          m_gpgpu_sim->set_kernel_core_range(kernel, core_range);
        }
      }
    }
    
    for (auto k : kernels_info) {
      bool stream_busy = false;
      for (auto s : busy_streams) {
        if (s == k->get_cuda_stream_id()) stream_busy = true;
      }
      //std::cout << "Kernel " << k->get_name() << " (uid:" << k->get_uid() 
      //          << ", stream:" << k->get_cuda_stream_id() 
      //          << ") - stream_busy:" << stream_busy 
      //          << ", can_start:" << m_gpgpu_sim->can_start_kernel()
      //          << ", was_launched:" << k->was_launched() << std::endl;
                
      if (!stream_busy && m_gpgpu_sim->can_start_kernel() &&
          !k->was_launched()) {
        //std::cout << ">>> LAUNCHING kernel name: " << k->get_name()
        //          << " uid: " << k->get_uid()
        //          << " cuda_stream_id: " << k->get_cuda_stream_id()
        //          << " at cycle: " << m_gpgpu_sim->gpu_sim_cycle << std::endl;
        
        // Apply pre-calculated global core partitioning
        if (enable_stream_partitioning && m_gpgpu_sim->get_config().get_dynamic_core_scheduling()
          && global_dynamic_core_ranges.count(k->get_cuda_stream_id())) {
          auto core_range = global_dynamic_core_ranges[k->get_cuda_stream_id()];
          std::cout << "APPLYING DYNAMIC CORE PARTITIONING: Stream " << k->get_cuda_stream_id() 
                    << " using core range: " << k->print_core_range() << std::endl;
          // Set core range for this kernel
          m_gpgpu_sim->set_kernel_core_range(k, core_range);
          //std::cout << "Set core range for kernel " << k->get_name() << " stream " << k->get_cuda_stream_id() 
          //<< " using core range: " << k->print_core_range() << std::endl;
        } else if (enable_stream_partitioning && m_gpgpu_sim->get_config().get_dyno_core_scheduling()
          && global_dynamic_core_ranges.count(k->get_cuda_stream_id())) {
          auto core_range = global_dynamic_core_ranges[k->get_cuda_stream_id()];
          std::cout << "APPLYING DYNCORE PARTITIONING: Stream " << k->get_cuda_stream_id() 
                    << " using core range: " << k->print_core_range() << std::endl;
          // Set core range for this kernel
          m_gpgpu_sim->set_kernel_core_range(k, core_range);
        }
        else if (enable_stream_partitioning && m_gpgpu_sim->get_config().get_stream_intlv_core()
          && global_stream_core_ranges_set.count(k->get_cuda_stream_id())) {
          auto core_range = global_stream_core_ranges_set[k->get_cuda_stream_id()];
          std::cout << "APPLYING SHARED GLOBAL STREAM PARTITIONING: Stream " << k->get_cuda_stream_id() 
                    << " using core range: " << k->print_core_range() << std::endl;
          // Set core range for this kernel
          m_gpgpu_sim->set_kernel_core_range(k, core_range);
        } else {
          auto core_range = global_stream_core_ranges[k->get_cuda_stream_id()];
          unsigned start_core = core_range.first;
          unsigned end_core = core_range.second;
          std::cout << "APPLYING ISOLATED GLOBAL STREAM PARTITIONING: Stream " << k->get_cuda_stream_id() 
                    << " using cores [" << start_core << "-" << end_core << "]" << std::endl;
          // Set core range for this kernel
          m_gpgpu_sim->set_kernel_core_range(k, start_core, end_core);
        }
        m_gpgpu_sim->launch(k);
        k->set_launched();
        busy_streams.push_back(k->get_cuda_stream_id());
        
        std::cout << "Updated busy_streams: ";
        for (auto s : busy_streams) {
          std::cout << s << " ";
        }
        std::cout << std::endl;
      }
    }

    unsigned finished_kernel_uid = simulate();
    // cleanup finished kernel
    if (finished_kernel_uid || m_gpgpu_sim->cycle_insn_cta_max_hit() ||
        !m_gpgpu_sim->active()) {
      cleanup(finished_kernel_uid);
    }

    if (sim_cycles) {
      m_gpgpu_sim->update_stats();
      m_gpgpu_context->print_simulation_time();
    }

    // commandlist_index, commandlist.size(), kernels_info.size()
    //printf("commandlist_index: %d, commandlist.size(): %d, kernels_info.size(): %d\n",
    //  commandlist_index, commandlist.size(), kernels_info.size());
    
    // Check minimum simulation time before exiting the loop
    if (commandlist_index >= commandlist.size() && kernels_info.empty()) {
      check_and_restart_for_min_simulation_time();
    }
    
    if (m_gpgpu_sim->cycle_insn_cta_max_hit()) {
      printf(
          "GPGPU-Sim: ** break due to reaching the maximum cycles (or "
          "instructions) **\n");
      fflush(stdout);
      break;
    }
  }
}

void accel_sim_framework::parse_commandlist() {
  // gulp up as many commands as possible - either cpu_gpu_mem_copy
  // or kernel_launch - until the vector "kernels_info" has reached
  // the window_size or we have read every command from commandlist
  while (kernels_info.size() < window_size && commandlist_index < commandlist.size()) {
    trace_kernel_info_t *kernel_info = NULL;
    if (commandlist[commandlist_index].m_type == command_type::cpu_gpu_mem_copy) {
      size_t addre, Bcount;
      std::string dump_filename = "";
      tracer.parse_memcpy_info(commandlist[commandlist_index].command_string, addre, Bcount,
                               dump_filename);
      std::cout << "launching memcpy command : "
                << commandlist[commandlist_index].command_string << std::endl;
      m_gpgpu_sim->perf_memcpy_to_gpu(addre, Bcount);
      commandlist_index++;
    } else if (commandlist[commandlist_index].m_type == command_type::kernel_launch) {
      // Read trace header info for window_size number of kernels
      kernel_trace_t *kernel_trace_info =
          tracer.parse_kernel_info(commandlist[commandlist_index].command_string,
                                  is_multi_trace, commandlist[commandlist_index].trace_id);
      kernel_info = create_kernel_info(kernel_trace_info, m_gpgpu_context,
                                       &tconfig, &tracer);
      if (is_multi_trace) {
        // if the kernel is from a multi-trace, we need to set the trace id
        kernel_info->set_streamID(commandlist[commandlist_index].trace_id);
        printf("Kernel %s is from trace %d, setting stream ID to %lld\n",
               kernel_info->name().c_str(), commandlist[commandlist_index].trace_id,
               kernel_info->get_streamID());
      }

      kernels_info.push_back(kernel_info);
      stream_kernel_map[kernel_info->get_cuda_stream_id()]++;  // Map stream ID to kernel ID
      std::cout << "Header info loaded for kernel command : "
                << commandlist[commandlist_index].command_string << std::endl;
      commandlist_index++;
    } else {
      // unsupported commands will fail the simulation
      assert(0 && "Undefined Command");
    }
  }
}

void accel_sim_framework::cleanup(unsigned finished_kernel) {
  bool end_of_one_stream = false;
  trace_kernel_info_t *k = NULL;
  unsigned long long finished_kernel_cuda_stream_id = -1;
  for (unsigned j = 0; j < kernels_info.size(); j++) {
    k = kernels_info.at(j);
    if (k->get_uid() == finished_kernel ||
        m_gpgpu_sim->cycle_insn_cta_max_hit() || !m_gpgpu_sim->active()) {
      for (unsigned int l = 0; l < busy_streams.size(); l++) {
        if (busy_streams.at(l) == k->get_cuda_stream_id()) {
          finished_kernel_cuda_stream_id = k->get_cuda_stream_id();
          busy_streams.erase(busy_streams.begin() + l);
          break;
        }
      }

      stream_kernel_map[k->get_cuda_stream_id()]--;
      if (m_gpgpu_sim->getShaderCoreConfig()->gpgpu_stream_partitioning&&
        stream_kernel_map[k->get_cuda_stream_id()] == 0) {
        if (enable_stream_repetition) {
            m_gpgpu_sim->restart_stream(k->get_cuda_stream_id());
        } else {
            // since we only support two stream partitioning modes,
            // we will allocate all the gpus cores to the other stream
            for (unsigned i = 0; i < kernels_info.size(); i++){
              if (kernels_info[i]->get_cuda_stream_id() != k->get_cuda_stream_id()) {
                unsigned start_core = 0;
                unsigned end_core = m_gpgpu_sim->get_config().num_shader();
                m_gpgpu_sim->set_kernel_core_range(kernels_info[i], start_core, end_core);
                printf("Stream %llu has no more kernels, allocating all cores to stream %llu\n",
                       k->get_cuda_stream_id(), kernels_info[i]->get_cuda_stream_id());
                m_gpgpu_sim->release_core_range_limit();
                end_of_one_stream = true;
              }
            }
        }
      }
      
      // Check if this stream has completed all its original kernels
      if (stream_kernel_map[k->get_cuda_stream_id()] == 0 && !stream_completed[k->get_cuda_stream_id()]) {
        stream_completed[k->get_cuda_stream_id()] = true;
        std::cout << "Stream " << k->get_cuda_stream_id() << " has completed its original workload" << std::endl;
        
        // Check if we should restart this stream
        if (enable_stream_repetition) {
          restart_completed_stream(k->get_cuda_stream_id());
        }
      }
      tracer.kernel_finalizer(k->get_trace_info());
      delete k->entry();
      delete k;
      kernels_info.erase(kernels_info.begin() + j);
      if (!m_gpgpu_sim->cycle_insn_cta_max_hit() && m_gpgpu_sim->active())
        break;
    }
  }
  assert(k);
  m_gpgpu_sim->print_stats(finished_kernel_cuda_stream_id);
  
  // Check if all streams have completed and no more commands are available
  bool all_streams_completed = true;
  for (auto stream_id : global_unique_streams) {
    if (!stream_completed[stream_id] || stream_repetition_count[stream_id] < max_repetitions) {
      all_streams_completed = false;
      break;
    }
  }

  //if (all_streams_completed) {
    //print out the simulation time
    //std::cout << "Simulation time: " << m_gpgpu_sim->gpu_sim_cycle << std::endl;
    //std::cout << " absolute cycle: " << m_gpgpu_sim->gpu_core_abs_cycle << std::endl;
    //std::cout << " total cycle: " << m_gpgpu_sim->gpu_tot_sim_cycle << std::endl;
    //printf("all_streams_completed: %d end_of_one_stream: %d global_unique_streams.size(): %d simulation_start_cycle: %d gpu_sim_cycle: %d min_simulation_cycles: %d\n",
    //all_streams_completed, end_of_one_stream, global_unique_streams.size(), simulation_start_cycle, m_gpgpu_sim->gpu_sim_cycle, min_simulation_cycles);
  //}
  
  // Check minimum simulation time for two-stream mode
  if (enable_min_simulation_time && global_unique_streams.size() == 2 && all_streams_completed) {
    unsigned long long current_cycle = m_gpgpu_sim->gpu_sim_cycle;
    unsigned long long elapsed_cycles = current_cycle - simulation_start_cycle;
    
    std::cout << "=== MINIMUM SIMULATION TIME CHECK ===" << std::endl;
    std::cout << "Current cycle: " << current_cycle << std::endl;
    std::cout << "Elapsed cycles: " << elapsed_cycles << std::endl;
    std::cout << "Minimum required cycles: " << min_simulation_cycles << std::endl;
    
    if (elapsed_cycles < min_simulation_cycles) {
      std::cout << "Both streams completed too early! Restarting both streams..." << std::endl;
      std::cout << "Need " << (min_simulation_cycles - elapsed_cycles) << " more cycles" << std::endl;
      
      // Restart both streams
      for (auto stream_id : global_unique_streams) {
        restart_completed_stream(stream_id);
      }
      
      // Reset completion flags
      for (auto stream_id : global_unique_streams) {
        stream_completed[stream_id] = false;
      }
      
      both_streams_completed_early = true;
      std::cout << "=== BOTH STREAMS RESTARTED FOR MINIMUM SIMULATION TIME ===" << std::endl;
      return; // Continue simulation
    } else {
      std::cout << "Minimum simulation time requirement met!" << std::endl;
    }
  }
  
  // Only exit if all streams have completed their maximum repetitions AND minimum time is met
  if (end_of_one_stream && all_streams_completed && commandlist_index >= commandlist.size()) {
    if (!enable_min_simulation_time || global_unique_streams.size() != 2 || 
        (m_gpgpu_sim->gpu_sim_cycle - simulation_start_cycle) >= min_simulation_cycles) {
      std::cout << "=== ALL STREAMS COMPLETED MAXIMUM REPETITIONS - ENDING SIMULATION ===" << std::endl;
      exit(0);
    }
  }
}

unsigned accel_sim_framework::simulate() {
  unsigned finished_kernel_uid = 0;
  do {
    if (!m_gpgpu_sim->active()) break;

    // performance simulation
    if (m_gpgpu_sim->active()) {
      m_gpgpu_sim->cycle();
      sim_cycles = true;
      m_gpgpu_sim->deadlock_check();
    } else {
      if (m_gpgpu_sim->cycle_insn_cta_max_hit()) {
        m_gpgpu_context->the_gpgpusim->g_stream_manager
            ->stop_all_running_kernels();
        break;
      }
    }

    active = m_gpgpu_sim->active();
    finished_kernel_uid = m_gpgpu_sim->finished_kernel();
  } while (active && !finished_kernel_uid);
  return finished_kernel_uid;
}

trace_kernel_info_t *accel_sim_framework::create_kernel_info(kernel_trace_t *kernel_trace_info,
                                        gpgpu_context *m_gpgpu_context,
                                        trace_config *config,
                                        trace_parser *parser) {
  gpgpu_ptx_sim_info info;
  info.smem = kernel_trace_info->shmem;
  info.regs = kernel_trace_info->nregs;
  dim3 gridDim(kernel_trace_info->grid_dim_x, kernel_trace_info->grid_dim_y,
               kernel_trace_info->grid_dim_z);
  dim3 blockDim(kernel_trace_info->tb_dim_x, kernel_trace_info->tb_dim_y,
                kernel_trace_info->tb_dim_z);
  trace_function_info *function_info =
      new trace_function_info(info, m_gpgpu_context);
  function_info->set_name(kernel_trace_info->kernel_name.c_str());
  trace_kernel_info_t *kernel_info = new trace_kernel_info_t(
      gridDim, blockDim, function_info, parser, config, kernel_trace_info);

  return kernel_info;
}

gpgpu_sim *accel_sim_framework::gpgpu_trace_sim_init_perf_model(
    int argc, const char *argv[], gpgpu_context *m_gpgpu_context,
    trace_config *m_config) {
  srand(1);
  print_splash();

  option_parser_t opp = option_parser_create();

  m_gpgpu_context->ptx_reg_options(opp);
  m_gpgpu_context->func_sim->ptx_opcocde_latency_options(opp);

  icnt_reg_options(opp);

  m_gpgpu_context->the_gpgpusim->g_the_gpu_config =
      new gpgpu_sim_config(m_gpgpu_context);
  m_gpgpu_context->the_gpgpusim->g_the_gpu_config->reg_options(
      opp);  // register GPU microrachitecture options
  m_config->reg_options(opp);

  // Add stream repetition options
  option_parser_register(opp, "-enable_stream_repetition", OPT_BOOL, &enable_stream_repetition,
                        "Enable automatic restart of completed streams until longest stream finishes (default: true)",
                        "true");
  option_parser_register(opp, "-max_stream_repetitions", OPT_UINT32, &max_repetitions,
                        "Maximum number of times a stream can be repeated (default: 10)",
                        "1000000");

  option_parser_cmdline(opp, argc, argv);  // parse configuration options
  fprintf(stdout, "GPGPU-Sim: Configuration options:\n\n");
  option_parser_print(opp, stdout);
  // Set the Numeric locale to a standard locale where a decimal point is a
  // "dot" not a "comma" so it does the parsing correctly independent of the
  // system environment variables
  assert(setlocale(LC_NUMERIC, "C"));
  m_gpgpu_context->the_gpgpusim->g_the_gpu_config->init();

  m_gpgpu_context->the_gpgpusim->g_the_gpu = new trace_gpgpu_sim(
      *(m_gpgpu_context->the_gpgpusim->g_the_gpu_config), m_gpgpu_context);

  m_gpgpu_context->the_gpgpusim->g_stream_manager =
      new stream_manager((m_gpgpu_context->the_gpgpusim->g_the_gpu),
                         m_gpgpu_context->func_sim->g_cuda_launch_blocking);

  m_gpgpu_context->the_gpgpusim->g_simulation_starttime = time((time_t *)NULL);

  return m_gpgpu_context->the_gpgpusim->g_the_gpu;
}

void accel_sim_framework::init() {
  active = false;
  sim_cycles = false;
  window_size = 0;
  commandlist_index = 0;

  assert(m_gpgpu_context);
  assert(m_gpgpu_sim);

  concurrent_kernel_sm =
      m_gpgpu_sim->getShaderCoreConfig()->gpgpu_concurrent_kernel_sm;
  window_size = concurrent_kernel_sm || m_gpgpu_sim->getShaderCoreConfig()->gpgpu_stream_partitioning
                    ? m_gpgpu_sim->get_config().get_max_concurrent_kernel()
                    : 1;
  assert(window_size > 0);
  commandlist = tracer.parse_commandlist_file();

  is_multi_trace = tracer.get_trace_num() > 1;
  trace1_kernel_num = tracer.get_trace1_kernel_num();
  trace2_kernel_num = tracer.get_trace2_kernel_num();

  kernels_info.reserve(window_size);
  
  // Initialize stream repetition variables
  enable_stream_repetition = true;  // Enable by default, can be made configurable
  max_repetitions = 100000;  // Default max repetitions, can be made configurable
  
  // Initialize minimum simulation time variables (for two-stream mode)
  enable_min_simulation_time = true;  // Enable by default for two-stream mode
  min_simulation_cycles = 10000000;  // Default minimum simulation cycles (1M cycles)
  simulation_start_cycle = 0;  // Will be set when simulation starts
  both_streams_completed_early = false;
  
  // GLOBAL STREAM ANALYSIS: Analyze all commands to find total unique streams
  global_stream_analysis();
  
  // Initialize stream tracking
  for (auto stream_id : global_unique_streams) {
    stream_completed[stream_id] = false;
    stream_repetition_count[stream_id] = 0;
    pending_stream_count++;
  }
  
  // Store original commands for each stream
  store_original_commands_by_stream();
}

void accel_sim_framework::global_stream_analysis() {
  std::cout << "=== GLOBAL STREAM ANALYSIS ===" << std::endl;
  
  global_unique_streams.clear();
  global_dynamic_core_ranges.clear();
  global_stream_core_ranges.clear();
  global_stream_core_ranges_set.clear();
  global_stream_core_ranges_vector.clear();
  
  // Parse all kernel commands to extract stream IDs
  for (const auto& command : commandlist) {
    if (command.m_type == command_type::kernel_launch) {
      // Parse the kernel header to get stream ID
      kernel_trace_t *kernel_trace_info = tracer.parse_kernel_info(command.command_string);
      if (kernel_trace_info) {
        if (is_multi_trace) {
          // If multi-trace, set the stream ID from the trace ID
          kernel_trace_info->cuda_stream_id = command.trace_id;
        }
        global_unique_streams.insert(kernel_trace_info->cuda_stream_id);
        std::cout << "Found kernel " << kernel_trace_info->kernel_name 
                  << " on stream " << kernel_trace_info->cuda_stream_id << std::endl;
      }
    }
  }
  
  // Pre-calculate core ranges for all streams
  unsigned total_cores = m_gpgpu_sim->get_config().num_shader();
  unsigned num_streams = global_unique_streams.size();
  
  stream_num = global_unique_streams.size();

  if (num_streams > 1) {
    unsigned cores_per_stream = total_cores / num_streams;
    
    std::cout << "GLOBAL ANALYSIS: Found " << num_streams << " unique streams, " 
              << cores_per_stream << " cores per stream (total: " << total_cores << ")" << std::endl;
    
    // Create sorted stream list for consistent core assignment
    std::vector<unsigned long long> stream_list(global_unique_streams.begin(), global_unique_streams.end());
    std::sort(stream_list.begin(), stream_list.end());

    if (m_gpgpu_sim->get_config().get_dyno_core_scheduling()) {
      m_gpgpu_sim->sampling_dyno_core_scheduling();
    } else if (m_gpgpu_sim->get_config().get_dynamic_core_scheduling()) {
      m_gpgpu_sim->sampling_dynamic_core_scheduling();
    } else if (m_gpgpu_sim->get_config().get_stream_intlv_core()) {
      // Pre-calculate core ranges for each stream interleave  mode
      for (unsigned i = 0; i < stream_list.size(); i++) {
        std::set<unsigned> core_range;
        unsigned long long stream_id = stream_list[i];
        unsigned start_core = stream_id == 0 ? 0 :1;
        unsigned end_core = stream_id == 0 ? total_cores -2 : total_cores -1;
        for (unsigned core = start_core; core <= end_core; core+=2) {
          core_range.insert(core);
        }
        for (auto core : core_range) {
          core_stream_mapping[core] = stream_id;
        }
        global_stream_core_ranges_set[stream_id] = core_range;

        std::vector<unsigned> core_range_vector;
        for (auto core : core_range) {
          core_range_vector.push_back(core);
        }
        std::sort(core_range_vector.begin(), core_range_vector.end());

        global_stream_core_ranges_vector[stream_id] = core_range_vector;
        std::cout << "GLOBAL: STREAM " << stream_id << " -> cores [" << start_core << "-" << end_core << "]" << std::endl;
      }
    } else {
      // Pre-calculate core ranges for each stream isolated mode
      for (unsigned i = 0; i < stream_list.size(); i++) {
        unsigned long long stream_id = stream_list[i];
        unsigned start_core = i * cores_per_stream;
        unsigned end_core = (i == num_streams - 1) ? 
                         total_cores - 1 : 
                         (i + 1) * cores_per_stream - 1;
        global_stream_core_ranges[stream_id] = std::make_pair(start_core, end_core);

        std::set<unsigned> core_range;
        for (unsigned core = start_core; core <= end_core; core+=1) {
          core_range.insert(core);
        }
        for (auto core : core_range) {
          core_stream_mapping[core] = stream_id;
        }

        std::vector<unsigned> core_range_vector;
        for (auto core : core_range) {
          core_range_vector.push_back(core);
        }
        std::sort(core_range_vector.begin(), core_range_vector.end());

        global_stream_core_ranges_set[stream_id] = core_range;
        global_stream_core_ranges_vector[stream_id] = core_range_vector;
        std::cout << "GLOBAL: STREAM " << stream_id << " -> cores [" << start_core << "-" << end_core << "]" << std::endl;
      }
    }

    for (unsigned core_id = 0; core_id < total_cores; core_id++) {
      shader_core_ctx *core = m_gpgpu_sim->get_core_by_sid(core_id);
      core->transition_done = true;
    }

  } else {
    std::cout << "GLOBAL ANALYSIS: Only " << num_streams << " stream found, no partitioning needed" << std::endl;
  }
  
  std::cout << "=== END GLOBAL STREAM ANALYSIS ===" << std::endl;
}


void accel_sim_framework::store_original_commands_by_stream() {
  std::cout << "=== STORING ORIGINAL COMMANDS BY STREAM ===" << std::endl;
  
  // Clear any existing stored commands
  stream_original_commands.clear();
  
  // Group commands by stream ID
  for (const auto& command : commandlist) {
    if (command.m_type == command_type::kernel_launch) {
      // Parse the kernel header to get stream ID
      kernel_trace_t *kernel_trace_info = tracer.parse_kernel_info(command.command_string);
      if (kernel_trace_info) {
        unsigned long long stream_id;
        if (is_multi_trace) {
          stream_id = command.trace_id;
        } else {
          stream_id = kernel_trace_info->cuda_stream_id;
        }
        
        // Store the command for this stream
        stream_original_commands[stream_id].push_back(command);
        std::cout << "Stored command for stream " << stream_id << ": " << command.command_string << std::endl;
      }
    }
  }
  
  std::cout << "=== END STORING ORIGINAL COMMANDS ===" << std::endl;
}

void accel_sim_framework::restart_completed_stream(unsigned long long stream_id) {
  if (!enable_stream_repetition || stream_repetition_count[stream_id] >= max_repetitions) {
    std::cout << "Stream " << stream_id << " will not be restarted (repetition limit reached or disabled)" << std::endl;
    return;
  }

  if (stream_completed_set.count(stream_id) == 0) {
    stream_completed_set.insert(stream_id);
    pending_stream_count--;
  }

  if (pending_stream_count == 0) {
    std::cout << "=== ALL STREAMS COMPLETED MAXIMUM REPETITIONS - ENDING SIMULATION ===" << std::endl;
    return;
  }
  
  std::cout << "=== RESTARTING STREAM " << stream_id << " (repetition " 
            << (stream_repetition_count[stream_id] + 1) << "/" << max_repetitions << ") ===" << std::endl;
  
  // Get the original commands for this stream
  auto& original_commands = stream_original_commands[stream_id];
  if (original_commands.empty()) {
    std::cout << "No original commands found for stream " << stream_id << std::endl;
    return;
  }
  
  // Append the original commands to the end of the commandlist
  for (const auto& command : original_commands) {
    commandlist.push_back(command);
    std::cout << "Added command to restart stream " << stream_id << ": " << command.command_string << std::endl;
  }
  
  // Update repetition count
  stream_repetition_count[stream_id]++;
  
  // Mark stream as not completed for the new iteration
  stream_completed[stream_id] = false;
  
  std::cout << "=== STREAM " << stream_id << " RESTARTED ===" << std::endl;
}

void accel_sim_framework::check_and_restart_for_min_simulation_time() {
  // Only check for two-stream mode with minimum simulation time enabled
  if (!enable_min_simulation_time || global_unique_streams.size() != 2) {
    return;
  }
  
  unsigned long long current_cycle = m_gpgpu_sim->gpu_sim_cycle;
  unsigned long long elapsed_cycles = current_cycle - simulation_start_cycle;
  
  std::cout << "=== MINIMUM SIMULATION TIME CHECK (LOOP EXIT) ===" << std::endl;
  std::cout << "Current cycle: " << current_cycle << std::endl;
  std::cout << "Elapsed cycles: " << elapsed_cycles << std::endl;
  std::cout << "Minimum required cycles: " << min_simulation_cycles << std::endl;
  std::cout << "Commandlist empty: " << (commandlist_index >= commandlist.size()) << std::endl;
  std::cout << "Kernels empty: " << kernels_info.empty() << std::endl;
  
  if (elapsed_cycles < min_simulation_cycles) {
    std::cout << "Both streams completed too early! Restarting both streams..." << std::endl;
    std::cout << "Need " << (min_simulation_cycles - elapsed_cycles) << " more cycles" << std::endl;
    
    // Restart both streams by adding their original commands back to commandlist
    for (auto stream_id : global_unique_streams) {
      auto& original_commands = stream_original_commands[stream_id];
      if (!original_commands.empty()) {
        for (const auto& command : original_commands) {
          commandlist.push_back(command);
          std::cout << "Added command to restart stream " << stream_id << ": " << command.command_string << std::endl;
        }
        
        // Update repetition count
        stream_repetition_count[stream_id]++;
        
        // Reset completion flags
        stream_completed[stream_id] = false;
        
        std::cout << "Stream " << stream_id << " restarted (repetition " << stream_repetition_count[stream_id] << ")" << std::endl;
      }
    }
    
    both_streams_completed_early = true;
    std::cout << "=== BOTH STREAMS RESTARTED FOR MINIMUM SIMULATION TIME ===" << std::endl;
    std::cout << "Continuing simulation..." << std::endl;
  } else {
    std::cout << "Minimum simulation time requirement met!" << std::endl;
    std::cout << "Simulation will exit normally." << std::endl;
  }
}

void accel_sim_framework::reset_simulation_for_policy_change(const std::string& new_policy, 
                                                           bool bypass_stream0, 
                                                           bool bypass_stream1) {
  printf("=== RESETTING SIMULATION FOR POLICY CHANGE: %s ===\n", new_policy.c_str());
  
  // Clear all kernel states
  for (auto k : kernels_info) {
    k->reset_launched();
  }
  busy_streams.clear();        // Clear busy streams
  commandlist_index = 0;       // Reset command list index
  
  // Reset stream completion tracking
  for (auto stream_id : global_unique_streams) {
    stream_completed[stream_id] = false;
    stream_repetition_count[stream_id] = 0;
  }
  
  // Apply new policy
  m_gpgpu_sim->update_core_allocation_for_policy(new_policy, bypass_stream0, bypass_stream1);
  
  // Reset GPU simulation state (clears execution state and invalidates caches)
  m_gpgpu_sim->reset_simulation_state();
  
  printf("=== SIMULATION RESET COMPLETE - READY FOR NEW POLICY ===\n");
}
