#!/bin/bash

# Echo a message to indicate that the entrypoint script is running
echo "Running entrypoint script..."

# Activate the Conda environment
echo "Activating the Gaussian Splatting Conda environment..."
source /opt/conda/bin/activate gaussian_splatting

# Check CUDA availability
echo "Checking for CUDA..."
if ! nvcc --version; then
    echo "CUDA not found, exiting..."
    exit 1
else
    echo "CUDA found: $(nvcc --version)"
fi

# Any other setup tasks can be added here
pip install ./gaussian-splatting/submodules/simple-knn/
pip install ./gaussian-splatting/submodules/diff-gaussian-rasterization
#conda install -c conda-forge opencv -y

# Execute the command passed to the Docker container
echo "Executing command: $@"
exec "$@"

