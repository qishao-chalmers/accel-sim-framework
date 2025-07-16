#!/bin/bash
#SBATCH -t 1-0:00:00 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=rodinia_3-particlefilter_naive__x_128__y_128__z_10__np_1000
#SBATCH --output=./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log
#SBATCH --error=./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log

# Load any necessary modules (uncomment if needed)
# module load cuda/11.0

# Set working directory
cd "$(dirname "$0")/.."

# Create log directory
mkdir -p "./logs"

# Check if trace file exists
if [[ ! -f "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g" ]]; then
    echo "[ERROR] Trace file not found: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g" | tee "./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log"
    exit 1
fi

# Check if accel-sim exists
if [[ ! -x "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" ]]; then
    echo "[ERROR] Accel-sim not found or not executable: /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" | tee "./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log"
    exit 1
fi

echo "================================================================"
echo "Running: rodinia_3-particlefilter_naive (_x_128__y_128__z_10__np_1000)"
echo "Trace: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g"
echo "Log: ./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log"
echo "Start time: $(date)"
echo "================================================================"

# Record start time
start_time=$(date +%s)

# Run simulation
/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g" >> "./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log" 2>&1

status=$?
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Record completion info
{
    echo "[INFO] Simulation completed at $(date)"
    echo "[INFO] Elapsed time: ${elapsed}s"
    echo "[INFO] Exit status: $status"
} | tee -a "./logs/rodinia_3-particlefilter_naive-_x_128__y_128__z_10__np_1000.log"

# Report status
if [[ $status -eq 0 ]]; then
    echo "[OK] rodinia_3-particlefilter_naive (_x_128__y_128__z_10__np_1000) completed successfully in ${elapsed}s"
else
    echo "[ERROR] rodinia_3-particlefilter_naive (_x_128__y_128__z_10__np_1000) FAILED (exit $status)"
fi

echo "================================================================"
exit $status
