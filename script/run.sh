#!/usr/bin/env bash
# Optimized GPU Simulator Runner
# Executes accel-sim for multiple trace files with proper error handling and logging

set -uo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
ACCEL_SIM="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin/release/accel-sim.out"
GPUGPUSIM_CONFIG="./gpgpusim.config"
TRACE_CONFIG="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config"
LOG_DIR="./logs"
TIME_LIMIT=7200  # half an hour per simulation

# Base directory for trace files
HW_RUN_BASE="/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run"

# /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin/release/accel-sim.out -config ./gpgpusim.config -config /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config -trace /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/myocyte-rodinia-3.1/100_1_0/traces/kernelslist.g 

# Create log directory
mkdir -p "$LOG_DIR"

# Function to run a single simulation
run_simulation() {
    local trace_file="$1"
    local app_name="$2"
    local variant="$3"
    
    # Generate log filename
    local log_file="$LOG_DIR/${app_name}-${variant}.log"
    
    echo "================================================================"
    echo "Running: $app_name ($variant)"
    echo "Trace: $trace_file"
    echo "Log: $log_file"
    echo "----------------------------------------------------------------"
    
    # Check if trace file exists
    if [[ ! -f "$trace_file" ]]; then
        echo "[ERROR] Trace file not found: $trace_file" | tee "$log_file"
        return 1
    fi
    
    # Check if accel-sim exists
    if [[ ! -x "$ACCEL_SIM" ]]; then
        echo "[ERROR] Accel-sim not found or not executable: $ACCEL_SIM" | tee "$log_file"
        return 1
    fi
    
    # Record start time
    local start_time=$(date +%s)
    echo "[INFO] Starting simulation at $(date)" | tee -a "$log_file"
    
    # Run simulation with timeout
    timeout --preserve-status ${TIME_LIMIT}s "$ACCEL_SIM" \
        -config "$GPUGPUSIM_CONFIG" \
        -config "$TRACE_CONFIG" \
        -trace "$trace_file" >> "$log_file" 2>&1
    
    local status=$?
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    
    # Record completion info
    {
        echo "[INFO] Simulation completed at $(date)"
        echo "[INFO] Elapsed time: ${elapsed}s"
        echo "[INFO] Exit status: $status"
    } | tee -a "$log_file"
    
    # Report status
    if [[ $status -eq 124 ]]; then
        echo "[WARN] $app_name ($variant) TIMED OUT after ${TIME_LIMIT}s"
    elif [[ $status -ne 0 ]]; then
        echo "[ERROR] $app_name ($variant) FAILED (exit $status)"
    else
        echo "[OK] $app_name ($variant) completed successfully in ${elapsed}s"
    fi
    
    echo
    return $status
}

# Function to extract app name and variant from trace path
get_app_info() {
    local trace_path="$1"
    local app_name=""
    local variant=""
    
    # Extract app name and variant from path
    if [[ "$trace_path" =~ /([^/]+)-rodinia-3\.1/([^/]+)/traces/kernelslist\.g$ ]]; then
        app_name="rodinia_3-${BASH_REMATCH[1]}"
        variant="${BASH_REMATCH[2]}"
    elif [[ "$trace_path" =~ /([^/]+)-rodinia-2\.0-ft/([^/]+)/traces/kernelslist\.g$ ]]; then
        app_name="rodinia_2-${BASH_REMATCH[1]}"
        variant="${BASH_REMATCH[2]}"
    elif [[ "$trace_path" =~ /parboil-([^/]+)/([^/]+)/traces/kernelslist\.g$ ]]; then
        app_name="parboil-${BASH_REMATCH[1]}"
        variant="${BASH_REMATCH[2]}"
    elif [[ "$trace_path" =~ /polybench-([^/]+)/([^/]+)/traces/kernelslist\.g$ ]]; then
        app_name="polybench-${BASH_REMATCH[1]}"
        variant="${BASH_REMATCH[2]}"
    elif [[ "$trace_path" =~ /([^/]+)_bench-tencore/([^/]+)/traces/kernelslist\.g$ ]]; then
        app_name="deepbench-${BASH_REMATCH[1]}"
        variant="${BASH_REMATCH[2]}"
    else
        # Fallback: use basename
        app_name=$(basename "$(dirname "$(dirname "$trace_path")")")
        variant=$(basename "$(dirname "$trace_path")")
    fi
    
    echo "$app_name" "$variant"
}

# Main execution
main() {
    echo "Starting GPU Simulator Batch Run"
    echo "Configuration:"
    echo "  Accel-sim: $ACCEL_SIM"
    echo "  GPGPU-Sim config: $GPUGPUSIM_CONFIG"
    echo "  Trace config: $TRACE_CONFIG"
    echo "  Log directory: $LOG_DIR"
    echo "  Time limit: ${TIME_LIMIT}s per simulation"
    echo "================================================================"
    echo
    
    # Array of trace files with their descriptions
    declare -a traces=(
        ######### Rodinia 2.0 workloads
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/heartwall-rodinia-2.0-ft/__data_test_avi_1___data_result_1_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/srad_v2-rodinia-2.0-ft/__data_matrix128x128_txt_0_127_0_127__5_2___data_result_matrix128x128_1_150_1_100__5_2_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/pathfinder-rodinia-2.0-ft/1000_20_5___data_result_1000_20_5_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/hotspot-rodinia-2.0-ft/30_6_40___data_result_30_6_40_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/bfs-rodinia-2.0-ft/__data_graph4096_txt___data_graph4096_result_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g"

        ######### Rodinia 3.1 workloads
        "${HW_RUN_BASE}/rodinia-3.1/11.0/myocyte-rodinia-3.1/100_1_0/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/srad_v1-rodinia-3.1/100_0_5_502_458/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/particlefilter_float-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/pathfinder-rodinia-3.1/100000_100_20___result_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/nn-rodinia-3.1/__data_filelist_4__r_5__lat_30__lng_90/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/backprop-rodinia-3.1/65536/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g"
        # NEVER RUN THIS!!!!! it takes too long
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/lavaMD-rodinia-3.1/_boxes1d_10/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/hotspot-rodinia-3.1/512_2_2___data_temp_512___data_power_512_output_out/traces/kernelslist.g"
        # DEADLOCK
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/hotspot-rodinia-3.1/1024_2_2___data_temp_1024___data_power_1024_output_out/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/lud-rodinia-3.1/_i___data_512_dat/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/lud-rodinia-3.1/_s_256__v/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/hybridsort-rodinia-3.1/__data_500000_txt/traces/kernelslist.g"
        # longer than 2 hours
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/hybridsort-rodinia-3.1/r/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_192_bmp__d_192x192__f__5__l_3/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix208_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_64/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/nw-rodinia-3.1/2048_10/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/b+tree-rodinia-3.1/file___data_mil_txt_command___data_command_txt/traces/kernelslist.g"
        # longer than 2 hour
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/kmeans-rodinia-3.1/_o__i___data_kdd_cup/traces/kernelslist.g"
        # longer than 2 hours
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/kmeans-rodinia-3.1/_o__i___data_28k_4x_features_txt/traces/kernelslist.g"
        #"${HW_RUN_BASE}/rodinia-3.1/11.0/kmeans-rodinia-3.1/_o__i___data_819200_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph4096_txt/traces/kernelslist.g"
        # DEADLOCK
        "${HW_RUN_BASE}/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph1MW_6_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g"

        #########  deepbench workloads
        "${HW_RUN_BASE}/deepbench/11.0/gemm_bench-tencore/train_half_1760_7000_1760_0_0/traces/kernelslist.g"
        "${HW_RUN_BASE}/deepbench/11.0/conv_bench-tencore/inference_half_700_161_1_1_32_20_5_0_0_2_2/traces/kernelslist.g"
        "${HW_RUN_BASE}/deepbench/11.0/rnn_bench-tencore/inference_half_1536_1_50_lstm/traces/kernelslist.g"

        #########  Parboil workloads
        "${HW_RUN_BASE}/parboil/11.0/parboil-bfs/_i___data_NY_input_graph_input_dat__o_bfs_NY_out/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-sad/_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin/traces/kernelslist.g"
        # longer than 2 hours
        #"${HW_RUN_BASE}/parboil/11.0/parboil-sgemm/_i___data_medium_input_matrix1_txt___data_medium_input_matrix2t_txt___data_medium_input_matrix2t_txt__o_matrix3_txt/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-mri-gridding/_i___data_small_input_small_uks__o_output_txt____32_0/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-stencil/_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-histo/_i___data_default_input_img_bin__o_ref_bmp____20_4/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-cutcp/_i___data_small_input_watbox_sl40_pqr__o_lattice_dat/traces/kernelslist.g"
        #DEADLOCK
        #"${HW_RUN_BASE}/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g"
        "${HW_RUN_BASE}/parboil/11.0/parboil-mri-q/_i___data_small_input_32_32_32_dataset_bin__o_32_32_32_dataset_out/traces/kernelslist.g"

        ######### polybench 
        # longer than 2 hours
        #"${HW_RUN_BASE}/polybench/11.0/polybench-3mm/NO_ARGS/traces/kernelslist.g"
        #"${HW_RUN_BASE}/polybench/11.0/polybench-gramschmidt/NO_ARGS/traces/kernelslist.g"
        # longer than 2 hours
        #"${HW_RUN_BASE}/polybench/11.0/polybench-2DConvolution/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-covariance/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-gesummv/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-fdtd2d/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-3DConvolution/NO_ARGS/traces/kernelslist.g"
        # longer than 2 hours
        #"${HW_RUN_BASE}/polybench/11.0/polybench-gemm/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g"
        "${HW_RUN_BASE}/polybench/11.0/polybench-correlation/NO_ARGS/traces/kernelslist.g"

    )
    
    # Statistics
    local total_simulations=${#traces[@]}
    local completed=0
    local failed=0
    local timed_out=0
    local skipped=0
    
    echo "Total simulations to run: $total_simulations"
    echo
    
    # Run each simulation
    for trace_file in "${traces[@]}"; do
        # Extract app name and variant
        read -r app_name variant < <(get_app_info "$trace_file")
        
        # Run simulation
        if run_simulation "$trace_file" "$app_name" "$variant"; then
            ((completed++))
        else
            local exit_status=$?
            if [[ $exit_status -eq 124 ]]; then
                ((timed_out++))
            elif [[ $exit_status -eq 1 ]]; then
                ((skipped++))
            else
                ((failed++))
            fi
        fi
    done
    
    # Summary
    echo "================================================================"
    echo "BATCH RUN COMPLETED"
    echo "================================================================"
    echo "Total simulations: $total_simulations"
    echo "Completed successfully: $completed"
    echo "Failed: $failed"
    echo "Timed out: $timed_out"
    echo "Skipped: $skipped"
    echo "================================================================"
    
    # Exit with error if any simulations failed
    if [[ $failed -gt 0 ]] || [[ $timed_out -gt 0 ]]; then
        exit 1
    fi
}

# Run main function
main "$@"
