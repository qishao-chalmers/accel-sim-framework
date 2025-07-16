# Source the setup environment with debug configuration
source ./gpu-simulator/setup_environment.sh
#cluster
#
#module load glew/2.2.0-glx
#module load buildtool-easybuild/4.8.0-hpce082752a2
# Build with debug configuration
cmake -S ./gpu-simulator/ -B ./gpu-simulator/build -DCMAKE_BUILD_TYPE=Release
cmake --build ./gpu-simulator/build -j 4
cmake --install ./gpu-simulator/build
