#include "accel-sim.h"
#include "accelsim_version.h"

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
    
    for (auto k : kernels_info) {
      bool stream_busy = false;
      for (auto s : busy_streams) {
        if (s == k->get_cuda_stream_id()) stream_busy = true;
      }
      std::cout << "Kernel " << k->get_name() << " (uid:" << k->get_uid() 
                << ", stream:" << k->get_cuda_stream_id() 
                << ") - stream_busy:" << stream_busy 
                << ", can_start:" << m_gpgpu_sim->can_start_kernel()
                << ", was_launched:" << k->was_launched() << std::endl;
                
      if (!stream_busy && m_gpgpu_sim->can_start_kernel() &&
          !k->was_launched()) {
        std::cout << ">>> LAUNCHING kernel name: " << k->get_name()
                  << " uid: " << k->get_uid()
                  << " cuda_stream_id: " << k->get_cuda_stream_id()
                  << " at cycle: " << m_gpgpu_sim->gpu_sim_cycle << std::endl;
        
        // Apply pre-calculated global core partitioning
        if (enable_stream_partitioning && global_stream_core_ranges.count(k->get_cuda_stream_id())) {
          auto core_range = global_stream_core_ranges[k->get_cuda_stream_id()];
          unsigned start_core = core_range.first;
          unsigned end_core = core_range.second;
          
          std::cout << "APPLYING GLOBAL STREAM PARTITIONING: Stream " << k->get_cuda_stream_id() 
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
  // end the simulation
  if (end_of_one_stream) {
    exit(0);
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
  
  // GLOBAL STREAM ANALYSIS: Analyze all commands to find total unique streams
  global_stream_analysis();
}

void accel_sim_framework::global_stream_analysis() {
  std::cout << "=== GLOBAL STREAM ANALYSIS ===" << std::endl;
  
  global_unique_streams.clear();
  global_stream_core_ranges.clear();
  
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
  
  if (num_streams > 1) {
    unsigned cores_per_stream = total_cores / num_streams;
    
    std::cout << "GLOBAL ANALYSIS: Found " << num_streams << " unique streams, " 
              << cores_per_stream << " cores per stream (total: " << total_cores << ")" << std::endl;
    
    // Create sorted stream list for consistent core assignment
    std::vector<unsigned long long> stream_list(global_unique_streams.begin(), global_unique_streams.end());
    std::sort(stream_list.begin(), stream_list.end());
    
    // Pre-calculate core ranges for each stream
    for (unsigned i = 0; i < stream_list.size(); i++) {
      unsigned long long stream_id = stream_list[i];
      unsigned start_core = i * cores_per_stream;
      unsigned end_core = (i == num_streams - 1) ? 
                         total_cores - 1 : 
                         (i + 1) * cores_per_stream - 1;
      
      global_stream_core_ranges[stream_id] = std::make_pair(start_core, end_core);
      
      std::cout << "GLOBAL: STREAM " << stream_id << " -> cores [" << start_core << "-" << end_core << "]" << std::endl;
    }
  } else {
    std::cout << "GLOBAL ANALYSIS: Only " << num_streams << " stream found, no partitioning needed" << std::endl;
  }
  
  std::cout << "=== END GLOBAL STREAM ANALYSIS ===" << std::endl;
}
