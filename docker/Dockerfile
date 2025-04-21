# Define base image.
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# CUDA architectures.
## A5500 is 86, A100 is 80, V100 is 70, T4 is 75, RTX 3000 series is 75
ARG CUDA_ARCHITECTURES=86;80;75;
## TORCH_CUDA_ARCH_LIST for torch_scatter
ENV TORCH_CUDA_ARCH_LIST="7.5 8.0 8.6"

# Set environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV CUDA_HOME="/usr/local/cuda"

# Install required apt packages and clear cache afterwards.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    openssh-server \
    cmake \
    curl \
    git \
    git-lfs \
    tig \
    zsh \
    tmux \
    vim \
    libatlas-base-dev \
    libhdf5-dev \
    libcgal-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libgflags-dev \
    libegl1 \
    libgl1 \
    libgomp1 \
    libopenblas-dev \
    protobuf-compiler \
    python3.10 \
    python3.10-dev \
    python3-pip \
    libsparsehash-dev \
    ninja-build \
    sudo \
    vim-tiny \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Git lfs
RUN git lfs install

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install pip packages
RUN pip install --upgrade pip

# Install packaging first
RUN pip install packaging

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# Install PyTorch and related packages
RUN pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu124

# Install all other packages from requirements.txt
RUN pip install -r /tmp/requirements.txt

# Debugging tools
RUN pip install ipdb

# Create non-root user
RUN useradd -m -d /home/user -g root -G sudo -u 1000 user
RUN usermod -aG sudo user
RUN echo "user:user" | chpasswd
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Copy local packages
COPY ./libs/pointops /workspace/libs/pointops
COPY ./libs/pointgroup_ops /workspace/libs/pointgroup_ops

# Install local packages
RUN pip install -e ./libs/pointops
RUN pip install -e ./libs/pointgroup_ops

# Set shell to zsh for user
RUN chsh -s /usr/bin/zsh user
