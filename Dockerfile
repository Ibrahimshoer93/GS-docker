# Base image with CUDA 11.6 and Ubuntu 20.04
FROM nvidia/cuda:11.6.2-devel-ubuntu20.04

# Set the environment to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update -y && apt install -y \
    build-essential wget cmake git ninja-build \
    libglew-dev libassimp-dev libboost-all-dev libgtk-3-dev \
    libopencv-dev libglfw3-dev libavdevice-dev libavcodec-dev \
    libeigen3-dev libembree-dev

# Install Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Set up CUDA environment variables
ENV PATH="/usr/local/cuda-11.6/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.6/lib64:$LD_LIBRARY_PATH"

# Validate CUDA installation
RUN nvcc --version

# Clone the Gaussian Splatting repository
WORKDIR /workspace
RUN git clone https://github.com/graphdeco-inria/gaussian-splatting --recursive

# Create and activate the Conda environment
WORKDIR /workspace/gaussian-splatting
COPY environment.yml .
RUN conda env create --file environment.yml


# Copy the API directory and app.py
COPY api /workspace/gaussian-splatting/api

# Ensure the environment is activated correctly
SHELL ["conda", "run", "-n", "gaussian_splatting", "/bin/bash", "-c"]
# Copy and set permissions for the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
#RUN apt-get update -y && apt-get install -y \
#     sudo
# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Expose the port the API will run on
EXPOSE 5000

# Start the Flask API
CMD ["bash", "-c", "source activate gaussian_splatting && python /workspace/gaussian-splatting/api/app.py"]

