#!/usr/bin/env bash
# Mixed trace execution commands
# Generated on tor 17 jul 2025 22:15:10 CEST

set -euo pipefail

# Configuration
ACCEL_SIM="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out"
GPUGPUSIM_CONFIG="./gpgpusim.config"
TRACE_CONFIG="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config"
LOG_DIR="./logs"

# Create log directory
mkdir -p "$LOG_DIR"

echo "Starting mixed trace executions..."
echo "================================================================"

# ================================================================
# FRIENDLY + FRIENDLY COMBINATIONS
# ================================================================

# friendly_friendly: polybench-atax (NO_ARGS) + polybench-bicg (NO_ARGS)
echo "Running friendly_friendly: polybench-atax (NO_ARGS) + polybench-bicg (NO_ARGS)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-atax_NO_ARGS_polybench-bicg_NO_ARGS.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-atax + polybench-bicg exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_polybench-bicg_NO_ARGS.log)"
else
    echo "Completed friendly_friendly: polybench-atax + polybench-bicg (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_polybench-bicg_NO_ARGS.log)"
fi

# friendly_friendly: polybench-atax (NO_ARGS) + parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out)
echo "Running friendly_friendly: polybench-atax (NO_ARGS) + parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-atax_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-atax + parboil-spmv exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log)"
else
    echo "Completed friendly_friendly: polybench-atax + parboil-spmv (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log)"
fi

# friendly_friendly: polybench-atax (NO_ARGS) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)
echo "Running friendly_friendly: polybench-atax (NO_ARGS) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-atax + rodinia_3-dwt2d exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
else
    echo "Completed friendly_friendly: polybench-atax + rodinia_3-dwt2d (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
fi

# friendly_friendly: polybench-atax (NO_ARGS) + rodinia_2-backprop (4096___data_result_4096_txt)
echo "Running friendly_friendly: polybench-atax (NO_ARGS) + rodinia_2-backprop (4096___data_result_4096_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-atax + rodinia_2-backprop exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log)"
else
    echo "Completed friendly_friendly: polybench-atax + rodinia_2-backprop (log: ./logs/friendly_friendly_polybench-atax_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log)"
fi

# friendly_friendly: polybench-bicg (NO_ARGS) + parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out)
echo "Running friendly_friendly: polybench-bicg (NO_ARGS) + parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-bicg_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-bicg + parboil-spmv exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log)"
else
    echo "Completed friendly_friendly: polybench-bicg + parboil-spmv (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out.log)"
fi

# friendly_friendly: polybench-bicg (NO_ARGS) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)
echo "Running friendly_friendly: polybench-bicg (NO_ARGS) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-bicg + rodinia_3-dwt2d exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
else
    echo "Completed friendly_friendly: polybench-bicg + rodinia_3-dwt2d (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
fi

# friendly_friendly: polybench-bicg (NO_ARGS) + rodinia_2-backprop (4096___data_result_4096_txt)
echo "Running friendly_friendly: polybench-bicg (NO_ARGS) + rodinia_2-backprop (4096___data_result_4096_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g" > "./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: polybench-bicg + rodinia_2-backprop exceeded 2-hour limit (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log)"
else
    echo "Completed friendly_friendly: polybench-bicg + rodinia_2-backprop (log: ./logs/friendly_friendly_polybench-bicg_NO_ARGS_rodinia_2-backprop_4096___data_result_4096_txt.log)"
fi

# friendly_friendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)
echo "Running friendly_friendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g" > "./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: parboil-spmv + rodinia_3-dwt2d exceeded 2-hour limit (log: ./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
else
    echo "Completed friendly_friendly: parboil-spmv + rodinia_3-dwt2d (log: ./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3.log)"
fi

# friendly_friendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-backprop (4096___data_result_4096_txt)
echo "Running friendly_friendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-backprop (4096___data_result_4096_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g" > "./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-backprop_4096___data_result_4096_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: parboil-spmv + rodinia_2-backprop exceeded 2-hour limit (log: ./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-backprop_4096___data_result_4096_txt.log)"
else
    echo "Completed friendly_friendly: parboil-spmv + rodinia_2-backprop (log: ./logs/friendly_friendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-backprop_4096___data_result_4096_txt.log)"
fi

# friendly_friendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-backprop (4096___data_result_4096_txt)
echo "Running friendly_friendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-backprop (4096___data_result_4096_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g" > "./logs/friendly_friendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-backprop_4096___data_result_4096_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_friendly: rodinia_3-dwt2d + rodinia_2-backprop exceeded 2-hour limit (log: ./logs/friendly_friendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-backprop_4096___data_result_4096_txt.log)"
else
    echo "Completed friendly_friendly: rodinia_3-dwt2d + rodinia_2-backprop (log: ./logs/friendly_friendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-backprop_4096___data_result_4096_txt.log)"
fi

# ================================================================
# FRIENDLY + UNFRIENDLY COMBINATIONS
# ================================================================

# friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)
echo "Running friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-atax + rodinia_2-nn exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
else
    echo "Completed friendly_unfriendly: polybench-atax + rodinia_2-nn (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
fi

# friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-atax + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed friendly_unfriendly: polybench-atax + rodinia_2-streamcluster (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_3-gaussian (_s_256)
echo "Running friendly_unfriendly: polybench-atax (NO_ARGS) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-atax + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed friendly_unfriendly: polybench-atax + rodinia_3-gaussian (log: ./logs/friendly_unfriendly_polybench-atax_NO_ARGS_rodinia_3-gaussian__s_256.log)"
fi

# friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)
echo "Running friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-bicg + rodinia_2-nn exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
else
    echo "Completed friendly_unfriendly: polybench-bicg + rodinia_2-nn (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
fi

# friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-bicg + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed friendly_unfriendly: polybench-bicg + rodinia_2-streamcluster (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_3-gaussian (_s_256)
echo "Running friendly_unfriendly: polybench-bicg (NO_ARGS) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: polybench-bicg + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed friendly_unfriendly: polybench-bicg + rodinia_3-gaussian (log: ./logs/friendly_unfriendly_polybench-bicg_NO_ARGS_rodinia_3-gaussian__s_256.log)"
fi

# friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)
echo "Running friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: parboil-spmv + rodinia_2-nn exceeded 2-hour limit (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
else
    echo "Completed friendly_unfriendly: parboil-spmv + rodinia_2-nn (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
fi

# friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: parboil-spmv + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed friendly_unfriendly: parboil-spmv + rodinia_2-streamcluster (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-gaussian (_s_256)
echo "Running friendly_unfriendly: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: parboil-spmv + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed friendly_unfriendly: parboil-spmv + rodinia_3-gaussian (log: ./logs/friendly_unfriendly_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__s_256.log)"
fi

# friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)
echo "Running friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_3-dwt2d + rodinia_2-nn exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
else
    echo "Completed friendly_unfriendly: rodinia_3-dwt2d + rodinia_2-nn (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
fi

# friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_3-dwt2d + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed friendly_unfriendly: rodinia_3-dwt2d + rodinia_2-streamcluster (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_3-gaussian (_s_256)
echo "Running friendly_unfriendly: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_3-dwt2d + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed friendly_unfriendly: rodinia_3-dwt2d + rodinia_3-gaussian (log: ./logs/friendly_unfriendly_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__s_256.log)"
fi

# friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)
echo "Running friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_2-backprop + rodinia_2-nn exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
else
    echo "Completed friendly_unfriendly: rodinia_2-backprop + rodinia_2-nn (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt.log)"
fi

# friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_2-backprop + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed friendly_unfriendly: rodinia_2-backprop + rodinia_2-streamcluster (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_3-gaussian (_s_256)
echo "Running friendly_unfriendly: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_unfriendly: rodinia_2-backprop + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed friendly_unfriendly: rodinia_2-backprop + rodinia_3-gaussian (log: ./logs/friendly_unfriendly_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__s_256.log)"
fi

# ================================================================
# FRIENDLY + NONFEELING COMBINATIONS
# ================================================================

# friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-atax + rodinia_2-lud exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed friendly_nonfeeling: polybench-atax + rodinia_2-lud (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-atax + rodinia_2-nw exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed friendly_nonfeeling: polybench-atax + rodinia_2-nw (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running friendly_nonfeeling: polybench-atax (NO_ARGS) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-atax + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed friendly_nonfeeling: polybench-atax + rodinia_3-gaussian (log: ./logs/friendly_nonfeeling_polybench-atax_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-bicg + rodinia_2-lud exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed friendly_nonfeeling: polybench-bicg + rodinia_2-lud (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-bicg + rodinia_2-nw exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed friendly_nonfeeling: polybench-bicg + rodinia_2-nw (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running friendly_nonfeeling: polybench-bicg (NO_ARGS) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: polybench-bicg + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed friendly_nonfeeling: polybench-bicg + rodinia_3-gaussian (log: ./logs/friendly_nonfeeling_polybench-bicg_NO_ARGS_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: parboil-spmv + rodinia_2-lud exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed friendly_nonfeeling: parboil-spmv + rodinia_2-lud (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: parboil-spmv + rodinia_2-nw exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed friendly_nonfeeling: parboil-spmv + rodinia_2-nw (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running friendly_nonfeeling: parboil-spmv (_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: parboil-spmv + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed friendly_nonfeeling: parboil-spmv + rodinia_3-gaussian (log: ./logs/friendly_nonfeeling_parboil-spmv__i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_3-dwt2d + rodinia_2-lud exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_3-dwt2d + rodinia_2-lud (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_3-dwt2d + rodinia_2-nw exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_3-dwt2d + rodinia_2-nw (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running friendly_nonfeeling: rodinia_3-dwt2d (__data_rgb_bmp__d_1024x1024__f__5__l_3) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_3-dwt2d + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_3-dwt2d + rodinia_3-gaussian (log: ./logs/friendly_nonfeeling_rodinia_3-dwt2d___data_rgb_bmp__d_1024x1024__f__5__l_3_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_2-backprop + rodinia_2-lud exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_2-backprop + rodinia_2-lud (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_2-backprop + rodinia_2-nw exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_2-backprop + rodinia_2-nw (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running friendly_nonfeeling: rodinia_2-backprop (4096___data_result_4096_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: friendly_nonfeeling: rodinia_2-backprop + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed friendly_nonfeeling: rodinia_2-backprop + rodinia_3-gaussian (log: ./logs/friendly_nonfeeling_rodinia_2-backprop_4096___data_result_4096_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# ================================================================
# UNFRIENDLY + UNFRIENDLY COMBINATIONS
# ================================================================

# unfriendly_unfriendly: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)
echo "Running unfriendly_unfriendly: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g" > "./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_unfriendly: rodinia_2-nn + rodinia_2-streamcluster exceeded 2-hour limit (log: ./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
else
    echo "Completed unfriendly_unfriendly: rodinia_2-nn + rodinia_2-streamcluster (log: ./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt.log)"
fi

# unfriendly_unfriendly: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_3-gaussian (_s_256)
echo "Running unfriendly_unfriendly: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_unfriendly: rodinia_2-nn + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed unfriendly_unfriendly: rodinia_2-nn + rodinia_3-gaussian (log: ./logs/unfriendly_unfriendly_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__s_256.log)"
fi

# unfriendly_unfriendly: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_3-gaussian (_s_256)
echo "Running unfriendly_unfriendly: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_3-gaussian (_s_256)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g" > "./logs/unfriendly_unfriendly_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__s_256.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_unfriendly: rodinia_2-streamcluster + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/unfriendly_unfriendly_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__s_256.log)"
else
    echo "Completed unfriendly_unfriendly: rodinia_2-streamcluster + rodinia_3-gaussian (log: ./logs/unfriendly_unfriendly_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__s_256.log)"
fi

# ================================================================
# UNFRIENDLY + NONFEELING COMBINATIONS
# ================================================================

# unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-nn + rodinia_2-lud exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-nn + rodinia_2-lud (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-nn + rodinia_2-nw exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-nn + rodinia_2-nw (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running unfriendly_nonfeeling: rodinia_2-nn (__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-nn + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-nn + rodinia_3-gaussian (log: ./logs/unfriendly_nonfeeling_rodinia_2-nn___data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_2-lud exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_2-lud (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_2-nw exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_2-nw (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running unfriendly_nonfeeling: rodinia_2-streamcluster (3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_2-streamcluster + rodinia_3-gaussian (log: ./logs/unfriendly_nonfeeling_rodinia_2-streamcluster_3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_2-lud (_v__b__i___data_64_dat)
echo "Running unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_2-lud (_v__b__i___data_64_dat)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-lud__v__b__i___data_64_dat.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_2-lud exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-lud__v__b__i___data_64_dat.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_2-lud (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-lud__v__b__i___data_64_dat.log)"
fi

# unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_2-nw exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_2-nw (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running unfriendly_nonfeeling: rodinia_3-gaussian (_s_256) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed unfriendly_nonfeeling: rodinia_3-gaussian + rodinia_3-gaussian (log: ./logs/unfriendly_nonfeeling_rodinia_3-gaussian__s_256_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# ================================================================
# NONFEELING + NONFEELING COMBINATIONS
# ================================================================

# nonfeeling_nonfeeling: rodinia_2-lud (_v__b__i___data_64_dat) + rodinia_2-nw (128_10___data_result_128_10_txt)
echo "Running nonfeeling_nonfeeling: rodinia_2-lud (_v__b__i___data_64_dat) + rodinia_2-nw (128_10___data_result_128_10_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g" > "./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_2-nw_128_10___data_result_128_10_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: nonfeeling_nonfeeling: rodinia_2-lud + rodinia_2-nw exceeded 2-hour limit (log: ./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
else
    echo "Completed nonfeeling_nonfeeling: rodinia_2-lud + rodinia_2-nw (log: ./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_2-nw_128_10___data_result_128_10_txt.log)"
fi

# nonfeeling_nonfeeling: rodinia_2-lud (_v__b__i___data_64_dat) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running nonfeeling_nonfeeling: rodinia_2-lud (_v__b__i___data_64_dat) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: nonfeeling_nonfeeling: rodinia_2-lud + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed nonfeeling_nonfeeling: rodinia_2-lud + rodinia_3-gaussian (log: ./logs/nonfeeling_nonfeeling_rodinia_2-lud__v__b__i___data_64_dat_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi

# nonfeeling_nonfeeling: rodinia_2-nw (128_10___data_result_128_10_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)
echo "Running nonfeeling_nonfeeling: rodinia_2-nw (128_10___data_result_128_10_txt) + rodinia_3-gaussian (_f___data_matrix4_txt)"
timeout 2h /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g" > "./logs/nonfeeling_nonfeeling_rodinia_2-nw_128_10___data_result_128_10_txt_rodinia_3-gaussian__f___data_matrix4_txt.log" 2>&1
timeout_status=$?
if [ $timeout_status -eq 124 ]; then
    echo "TIMEOUT: nonfeeling_nonfeeling: rodinia_2-nw + rodinia_3-gaussian exceeded 2-hour limit (log: ./logs/nonfeeling_nonfeeling_rodinia_2-nw_128_10___data_result_128_10_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
else
    echo "Completed nonfeeling_nonfeeling: rodinia_2-nw + rodinia_3-gaussian (log: ./logs/nonfeeling_nonfeeling_rodinia_2-nw_128_10___data_result_128_10_txt_rodinia_3-gaussian__f___data_matrix4_txt.log)"
fi


echo "================================================================"
echo "All mixed trace executions completed!"
echo "Check logs in: $LOG_DIR"
echo "================================================================"
