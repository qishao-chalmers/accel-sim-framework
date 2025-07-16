#!/bin/bash
#SBATCH -t 1-0:00:00 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=parboil-stencil__i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100
#SBATCH --output=./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log
#SBATCH --error=./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log

# Load any necessary modules (uncomment if needed)
# module load cuda/11.0

# Set working directory
cd "$(dirname "$0")/.."

# Create log directory
mkdir -p "./logs"

# Check if trace file exists
if [[ ! -f "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-stencil/_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100/traces/kernelslist.g" ]]; then
    echo "[ERROR] Trace file not found: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-stencil/_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100/traces/kernelslist.g" | tee "./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log"
    exit 1
fi

# Check if accel-sim exists
if [[ ! -x "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" ]]; then
    echo "[ERROR] Accel-sim not found or not executable: /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" | tee "./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log"
    exit 1
fi

echo "================================================================"
echo "Running: parboil-stencil (_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100)"
echo "Trace: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-stencil/_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100/traces/kernelslist.g"
echo "Log: ./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log"
echo "Start time: $(date)"
echo "================================================================"

# Record start time
start_time=$(date +%s)

# Run simulation
/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-stencil/_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100/traces/kernelslist.g" >> "./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log" 2>&1

status=$?
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Record completion info
{
    echo "[INFO] Simulation completed at $(date)"
    echo "[INFO] Elapsed time: ${elapsed}s"
    echo "[INFO] Exit status: $status"
} | tee -a "./logs/parboil-stencil-_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100.log"

# Report status
if [[ $status -eq 0 ]]; then
    echo "[OK] parboil-stencil (_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100) completed successfully in ${elapsed}s"
else
    echo "[ERROR] parboil-stencil (_i___data_small_input_128x128x32_bin__o_128x128x32_out____128_128_32_100) FAILED (exit $status)"
fi

echo "================================================================"
exit $status
