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
    ["backprop"]="./hw_run/rodinia-3.1/11.0/backprop-rodinia-3.1/65536/traces/kernelslist.g"
    ["bfs"]="./hw_run/rodinia-3.1/11.0/bfs-rodinia-3.1/__data_graph65536_txt/traces/kernelslist.g"
    ["btree"]="./hw_run/rodinia-3.1/11.0/b+tree-rodinia-3.1/file___data_mil_txt_command___data_command_txt/traces/kernelslist.g"
    ["dwt2d"]="./hw_run/rodinia-3.1/11.0/dwt2d-rodinia-3.1/__data_rgb_bmp__d_1024x1024__f__5__l_3/traces/kernelslist.g"
    ["gaussian"]="./hw_run/rodinia-3.1/11.0/gaussian-rodinia-3.1/_s_64/traces/kernelslist.g"
    ["hotspot"]="./hw_run/rodinia-3.1/11.0/hotspot-rodinia-3.1/1024_2_2___data_temp_1024___data_power_1024_output_out/traces/kernelslist.g"
    ["hotspot"]="./hw_run/rodinia-3.1/11.0/hotspot-rodinia-3.1/1024_2_2___data_temp_1024___data_power_1024_output_out/traces/kernelslist.g"
    ["hybridsort"]="./hw_run/rodinia-3.1/11.0/hybridsort-rodinia-3.1/__data_500000_txt/traces/kernelslist.g"
    ["kmeans"]="./hw_run/rodinia-3.1/11.0/kmeans-rodinia-3.1/_o__i___data_28k_4x_features_txt/traces/kernelslist.g"
    ["lavaMD"]="./hw_run/rodinia-3.1/11.0/lavaMD-rodinia-3.1/_boxes1d_10/traces/kernelslist.g"
    ["lud"]="./hw_run/rodinia-3.1/11.0/lud-rodinia-3.1/_i___data_512_dat/traces/kernelslist.g"
    ["myocyte"]="./hw_run/rodinia-3.1/11.0/myocyte-rodinia-3.1/100_1_0/traces/kernelslist.g"
    ["nn"]="./hw_run/rodinia-3.1/11.0/nn-rodinia-3.1/__data_filelist_4__r_5__lat_30__lng_90/traces/kernelslist.g"
    ["nw"]="./hw_run/rodinia-3.1/11.0/nw-rodinia-3.1/2048_10/traces/kernelslist.g"
    ["particlefilter"]="./hw_run/rodinia-3.1/11.0/particlefilter_naive-rodinia-3.1/_x_128__y_128__z_10__np_1000/traces/kernelslist.g"
    ["pathfinder"]="./hw_run/rodinia-3.1/11.0/pathfinder-rodinia-3.1/100000_100_20___result_txt/traces/kernelslist.g"
    ["srad"]="./hw_run/rodinia-3.1/11.0/srad_v1-rodinia-3.1/100_0_5_502_458/traces/kernelslist.g"
)

# Cache configurations
CACHE_CONFIGS=("cache28" "cache55" "cache82")

# Output directory
OUTPUT_DIR="./multi_trace_cache_partition/SM6_TITANX"
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
            echo "./gpu-simulator/bin/debug/accel-sim.out -trace \"${TRACES[$app1]} ${TRACES[$app2]}\" -config ./gpu-simulator/gpgpu-sim/configs/stream-cfgs/SM6_TITANX_$cache/gpgpusim.config -config ./gpu-simulator/configs/tested-cfgs/SM6_TITANX/trace.config"
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
