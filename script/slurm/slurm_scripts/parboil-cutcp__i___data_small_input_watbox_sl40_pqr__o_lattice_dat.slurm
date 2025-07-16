#!/bin/bash
#SBATCH -t 1-0:00:00 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --job-name=parboil-cutcp__i___data_small_input_watbox_sl40_pqr__o_lattice_dat
#SBATCH --output=./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log
#SBATCH --error=./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log

# Load any necessary modules (uncomment if needed)
# module load cuda/11.0

# Set working directory
cd "$(dirname "$0")/.."

# Create log directory
mkdir -p "./logs"

# Check if trace file exists
if [[ ! -f "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-cutcp/_i___data_small_input_watbox_sl40_pqr__o_lattice_dat/traces/kernelslist.g" ]]; then
    echo "[ERROR] Trace file not found: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-cutcp/_i___data_small_input_watbox_sl40_pqr__o_lattice_dat/traces/kernelslist.g" | tee "./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log"
    exit 1
fi

# Check if accel-sim exists
if [[ ! -x "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" ]]; then
    echo "[ERROR] Accel-sim not found or not executable: /home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out" | tee "./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log"
    exit 1
fi

echo "================================================================"
echo "Running: parboil-cutcp (_i___data_small_input_watbox_sl40_pqr__o_lattice_dat)"
echo "Trace: /home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-cutcp/_i___data_small_input_watbox_sl40_pqr__o_lattice_dat/traces/kernelslist.g"
echo "Log: ./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log"
echo "Start time: $(date)"
echo "================================================================"

# Record start time
start_time=$(date +%s)

# Run simulation
/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out \
    -config "./gpgpusim.config" \
    -config "/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config" \
    -trace "/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run/parboil/11.0/parboil-cutcp/_i___data_small_input_watbox_sl40_pqr__o_lattice_dat/traces/kernelslist.g" >> "./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log" 2>&1

status=$?
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Record completion info
{
    echo "[INFO] Simulation completed at $(date)"
    echo "[INFO] Elapsed time: ${elapsed}s"
    echo "[INFO] Exit status: $status"
} | tee -a "./logs/parboil-cutcp-_i___data_small_input_watbox_sl40_pqr__o_lattice_dat.log"

# Report status
if [[ $status -eq 0 ]]; then
    echo "[OK] parboil-cutcp (_i___data_small_input_watbox_sl40_pqr__o_lattice_dat) completed successfully in ${elapsed}s"
else
    echo "[ERROR] parboil-cutcp (_i___data_small_input_watbox_sl40_pqr__o_lattice_dat) FAILED (exit $status)"
fi

echo "================================================================"
exit $status
