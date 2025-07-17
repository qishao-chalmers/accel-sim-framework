#!/usr/bin/env bash
# Generate mixed trace commands for local execution

set -euo pipefail

# Configuration
ACCEL_SIM="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/bin_0714/release/accel-sim.out"
GPUGPUSIM_CONFIG="./gpgpusim.config"
TRACE_CONFIG="/home/qishao/Project/gpu_simulator/accel-multi-task/gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config"
LOG_DIR="./logs"
COMMANDS_FILE="./mixed_trace_commands.sh"

# Base directory for trace files
HW_RUN_BASE="/home/qishao/Project/gpu_simulator/accel-multi-task/hw_run"

# Create directories
mkdir -p "$LOG_DIR"

# Array of trace files with their descriptions
declare -a traces_share_friendly=(
    "${HW_RUN_BASE}/polybench/11.0/polybench-atax/NO_ARGS/traces/kernelslist.g"
    "${HW_RUN_BASE}/polybench/11.0/polybench-bicg/NO_ARGS/traces/kernelslist.g"
    "${HW_RUN_BASE}/parboil/11.0/parboil-spmv/_i___data_large_input_Dubcova3_mtx_bin___data_large_input_vector_bin__o_Dubcova3_mtx_out/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/backprop-rodinia-2.0-ft/4096___data_result_4096_txt/traces/kernelslist.g"
)

# Array of trace files with their descriptions
declare -a traces_share_unfriendly=(
    "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/nn-rodinia-2.0-ft/__data_filelist_4_3_30_90___data_filelist_4_3_30_90_result_txt/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/streamcluster-rodinia-2.0-ft/3_6_16_1024_1024_100_none_output_txt_1___data_result_3_6_16_1024_1024_100_none_1_txt/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_256/traces/kernelslist.g"
)

declare -a traces_share_nonfeeling=(
    "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/lud-rodinia-2.0-ft/_v__b__i___data_64_dat/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia_2.0-ft/11.0/nw-rodinia-2.0-ft/128_10___data_result_128_10_txt/traces/kernelslist.g"
    "${HW_RUN_BASE}/rodinia-3.1/11.0/gaussian-rodinia-3.1/_f___data_matrix4_txt/traces/kernelslist.g"
)

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
    else
        # Fallback: use basename
        app_name=$(basename "$(dirname "$(dirname "$trace_path")")")
        variant=$(basename "$(dirname "$trace_path")")
    fi
    
    echo "$app_name" "$variant"
}

# Function to generate mixed trace command
generate_mixed_command() {
    local trace1="$1"
    local trace2="$2"
    local mix_type="$3"
    
    # Extract app info for both traces
    read -r app1_name app1_variant < <(get_app_info "$trace1")
    read -r app2_name app2_variant < <(get_app_info "$trace2")
    
    # Create safe names for log file
    local safe_app1=$(echo "$app1_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local safe_variant1=$(echo "$app1_variant" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local safe_app2=$(echo "$app2_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local safe_variant2=$(echo "$app2_variant" | sed 's/[^a-zA-Z0-9_-]/_/g')
    
    local log_file="$LOG_DIR/${mix_type}_${safe_app1}_${safe_variant1}_${safe_app2}_${safe_variant2}.log"
    
    # Generate the command
    echo "# $mix_type: $app1_name ($app1_variant) + $app2_name ($app2_variant)"
    echo "echo \"Running $mix_type: $app1_name ($app1_variant) + $app2_name ($app2_variant)\""
    echo "$ACCEL_SIM \\"
    echo "    -config \"$GPUGPUSIM_CONFIG\" \\"
    echo "    -config \"$TRACE_CONFIG\" \\"
    echo "    -trace \"$trace1 $trace2\" > \"$log_file\" 2>&1"
    echo "echo \"Completed $mix_type: $app1_name + $app2_name (log: $log_file)\""
    echo ""
}

# Generate commands file header
cat > "$COMMANDS_FILE" << EOF
#!/usr/bin/env bash
# Mixed trace execution commands
# Generated on $(date)

set -euo pipefail

# Configuration
ACCEL_SIM="$ACCEL_SIM"
GPUGPUSIM_CONFIG="$GPUGPUSIM_CONFIG"
TRACE_CONFIG="$TRACE_CONFIG"
LOG_DIR="$LOG_DIR"

# Create log directory
mkdir -p "\$LOG_DIR"

echo "Starting mixed trace executions..."
echo "================================================================"

EOF

# Generate all mixed combinations
echo "Generating mixed trace commands..."

# 1. friendly + friendly
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# FRIENDLY + FRIENDLY COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_friendly[@]}"; do
    for j in "${!traces_share_friendly[@]}"; do
        if [[ $i -lt $j ]]; then  # Avoid duplicates and self-pairs
            generate_mixed_command "${traces_share_friendly[$i]}" "${traces_share_friendly[$j]}" "friendly_friendly" >> "$COMMANDS_FILE"
        fi
    done
done

# 2. friendly + unfriendly
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# FRIENDLY + UNFRIENDLY COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_friendly[@]}"; do
    for j in "${!traces_share_unfriendly[@]}"; do
        generate_mixed_command "${traces_share_friendly[$i]}" "${traces_share_unfriendly[$j]}" "friendly_unfriendly" >> "$COMMANDS_FILE"
    done
done

# 3. friendly + nonfeeling
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# FRIENDLY + NONFEELING COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_friendly[@]}"; do
    for j in "${!traces_share_nonfeeling[@]}"; do
        generate_mixed_command "${traces_share_friendly[$i]}" "${traces_share_nonfeeling[$j]}" "friendly_nonfeeling" >> "$COMMANDS_FILE"
    done
done

# 4. unfriendly + unfriendly
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# UNFRIENDLY + UNFRIENDLY COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_unfriendly[@]}"; do
    for j in "${!traces_share_unfriendly[@]}"; do
        if [[ $i -lt $j ]]; then  # Avoid duplicates and self-pairs
            generate_mixed_command "${traces_share_unfriendly[$i]}" "${traces_share_unfriendly[$j]}" "unfriendly_unfriendly" >> "$COMMANDS_FILE"
        fi
    done
done

# 5. unfriendly + nonfeeling
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# UNFRIENDLY + NONFEELING COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_unfriendly[@]}"; do
    for j in "${!traces_share_nonfeeling[@]}"; do
        generate_mixed_command "${traces_share_unfriendly[$i]}" "${traces_share_nonfeeling[$j]}" "unfriendly_nonfeeling" >> "$COMMANDS_FILE"
    done
done

# 6. nonfeeling + nonfeeling
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "# NONFEELING + NONFEELING COMBINATIONS" >> "$COMMANDS_FILE"
echo "# ================================================================" >> "$COMMANDS_FILE"
echo "" >> "$COMMANDS_FILE"

for i in "${!traces_share_nonfeeling[@]}"; do
    for j in "${!traces_share_nonfeeling[@]}"; do
        if [[ $i -lt $j ]]; then  # Avoid duplicates and self-pairs
            generate_mixed_command "${traces_share_nonfeeling[$i]}" "${traces_share_nonfeeling[$j]}" "nonfeeling_nonfeeling" >> "$COMMANDS_FILE"
        fi
    done
done

# Add footer
cat >> "$COMMANDS_FILE" << EOF

echo "================================================================"
echo "All mixed trace executions completed!"
echo "Check logs in: \$LOG_DIR"
echo "================================================================"
EOF

# Make the commands file executable
chmod +x "$COMMANDS_FILE"

# Calculate total combinations
friendly_count=${#traces_share_friendly[@]}
unfriendly_count=${#traces_share_unfriendly[@]}
nonfeeling_count=${#traces_share_nonfeeling[@]}

friendly_pairs=$((friendly_count * (friendly_count - 1) / 2))
unfriendly_pairs=$((unfriendly_count * (unfriendly_count - 1) / 2))
nonfeeling_pairs=$((nonfeeling_count * (nonfeeling_count - 1) / 2))
friendly_unfriendly_pairs=$((friendly_count * unfriendly_count))
friendly_nonfeeling_pairs=$((friendly_count * nonfeeling_count))
unfriendly_nonfeeling_pairs=$((unfriendly_count * nonfeeling_count))

total_combinations=$((friendly_pairs + unfriendly_pairs + nonfeeling_pairs + friendly_unfriendly_pairs + friendly_nonfeeling_pairs + unfriendly_nonfeeling_pairs))

echo
echo "================================================================"
echo "Mixed trace command generation completed!"
echo "Generated commands file: $COMMANDS_FILE"
echo
echo "Workload categories:"
echo "  - Share-friendly: $friendly_count workloads"
echo "  - Share-unfriendly: $unfriendly_count workloads"
echo "  - Share-nonfeeling: $nonfeeling_count workloads"
echo
echo "Mixed combinations:"
echo "  - Friendly + Friendly: $friendly_pairs combinations"
echo "  - Friendly + Unfriendly: $friendly_unfriendly_pairs combinations"
echo "  - Friendly + Nonfeeling: $friendly_nonfeeling_pairs combinations"
echo "  - Unfriendly + Unfriendly: $unfriendly_pairs combinations"
echo "  - Unfriendly + Nonfeeling: $unfriendly_nonfeeling_pairs combinations"
echo "  - Nonfeeling + Nonfeeling: $nonfeeling_pairs combinations"
echo "  - TOTAL: $total_combinations combinations"
echo
echo "To run all mixed traces:"
echo "  bash $COMMANDS_FILE"
echo
echo "To run specific combinations, edit the file and comment out unwanted sections."
echo "================================================================" 