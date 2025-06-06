#!/bin/bash 
## backprop
# ./hw_run/rodinia-3.1/11.0/backprop-rodinia-3.1/65536/traces/kernelslist.g

## bfs
# ./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g

## b+tree
# ./hw_run/rodinia-3.1/11.0/b+tree-rodinia-3.1/file___data_mil_txt_command___data_command_txt/traces/kernelslist.g

## gaussian
# ./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g

## dwt2d
# ./hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_192_bmp__d_192x192__f__5__l_3/traces/kernelslist.g
# ./hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g

## hotspot
# ./hw_run/rodinia-3.1/11.0/hotspot-rodinia-3.1/1024_2_2___data_temp_1024___data_power_1024_output_out/traces/kernelslist.g
# ./hw_run/rodinia-3.1/11.0/hotspot-rodinia-3.1/512_2_2___data_temp_512___data_power_512_output_out/traces/kernelslist.g

## bfs & gaussian

#./gpu-simulator/bin/debug/accel-sim.out -trace "./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g ./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g"    -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM7_GV100_cache55/gpgpusim.config -config ./gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config >  ./multi_trace_cache_partition/GV100/bfs_gaussian_cache55.out

#./gpu-simulator/bin/debug/accel-sim.out -trace "./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g ./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g"    -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM7_GV100_cache28/gpgpusim.config -config ./gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config >  ./multi_trace_cache_partition/GV100/bfs_gaussian_cache28.out

#./gpu-simulator/bin/debug/accel-sim.out -trace "./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g ./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g"    -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM7_GV100_cache82/gpgpusim.config -config ./gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config > ./multi_trace_cache_partition/GV100/bfs_gaussian_cache82.out


# Trace paths
declare -A TRACES=(
    ["bfs"]="./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g"
    ["gaussian"]="./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_16/traces/kernelslist.g"
    ["backprop"]="./hw_run/rodinia-3.1/11.0/backprop-rodinia-3.1/65536/traces/kernelslist.g"
    ["btree"]="./hw_run/rodinia-3.1/11.0/b+tree-rodinia-3.1/file___data_mil_txt_command___data_command_txt/traces/kernelslist.g"
    ["dwt2d"]="./hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_192_bmp__d_192x192__f__5__l_3/traces/kernelslist.g"
    ["hotspot"]="./hw_run/rodinia-3.1/11.0/hotspot-rodinia-3.1/1024_2_2___data_temp_1024___data_power_1024_output_out/traces/kernelslist.g"
)

# Cache configurations
CACHE_CONFIGS=("cache28" "cache55" "cache82")

# Output directory
OUTPUT_DIR="./multi_trace_cache_partition/GV100"
mkdir -p "$OUTPUT_DIR"

# Main execution loop
for app1 in "${!TRACES[@]}"; do
    for app2 in "${!TRACES[@]}"; do
        # Skip same application pairs
        if [[ "$app1" == "$app2" ]]; then
            continue
        fi
        
        for cache in "${CACHE_CONFIGS[@]}"; do
            echo "Running $app1 + $app2 with $cache..."
            # print out command first and then run it
            # this line is too long, so we split it
            echo "Command:"
            echo "./gpu-simulator/bin/debug/accel-sim.out -trace \"${TRACES[$app1]} ${TRACES[$app2]}\" -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM7_GV100_$cache/gpgpusim.config -config ./gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config"
            echo "Output will be saved to $OUTPUT_DIR/${app1}_${app2}_${cache}.out"
            
            ./gpu-simulator/bin/debug/accel-sim.out \
                -trace "${TRACES[$app1]} ${TRACES[$app2]}" \
                -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM7_GV100_$cache/gpgpusim.config \
                -config ./gpu-simulator/configs/tested-cfgs/SM7_GV100/trace.config \
                > "$OUTPUT_DIR/${app1}_${app2}_${cache}.out"
            
            echo "Completed $app1 + $app2 with $cache"
            echo
        done
    done
done