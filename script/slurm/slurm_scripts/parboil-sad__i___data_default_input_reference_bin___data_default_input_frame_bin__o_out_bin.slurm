#!/bin/bash
#SBATCH -t 1-0:00:00 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=parboil-sad__i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin
#SBATCH --output=./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log
#SBATCH --error=./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log

# Load any necessary modules (uncomment if needed)
# module load cuda/11.0

# Set working directory
cd "$(dirname "$0")/.."

# Create log directory
mkdir -p "./logs"

# Check if trace file exists
if [[ ! -f "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-sad/_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin/traces/kernelslist.g" ]]; then
    echo "[ERROR] Trace file not found: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-sad/_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin/traces/kernelslist.g" | tee "./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log"
    exit 1
fi

# Check if accel-sim exists
if [[ ! -x "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" ]]; then
    echo "[ERROR] Accel-sim not found or not executable: /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" | tee "./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log"
    exit 1
fi

echo "================================================================"
echo "Running: parboil-sad (_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin)"
echo "Trace: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-sad/_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin/traces/kernelslist.g"
echo "Log: ./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log"
echo "Start time: $(date)"
echo "================================================================"

# Record start time
start_time=$(date +%s)

# Run simulation
/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-sad/_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin/traces/kernelslist.g" >> "./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log" 2>&1

status=$?
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Record completion info
{
    echo "[INFO] Simulation completed at $(date)"
    echo "[INFO] Elapsed time: ${elapsed}s"
    echo "[INFO] Exit status: $status"
} | tee -a "./logs/parboil-sad-_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin.log"

# Report status
if [[ $status -eq 0 ]]; then
    echo "[OK] parboil-sad (_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin) completed successfully in ${elapsed}s"
else
    echo "[ERROR] parboil-sad (_i___data_default_input_reference_bin___data_default_input_frame_bin__o_out_bin) FAILED (exit $status)"
fi

echo "================================================================"
exit $status
