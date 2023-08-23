# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ARG TTS_COMMIT=cf7a9a757b2fdba206399c8d63f7de6addcbb040

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nginx \
        bash \
        dos2unix \
        git \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4 \
        apt-transport-https ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Stage 2: Install Web UI and python modules
FROM base as setup

# Create and use the Python venv
RUN python3 -m venv /venv

# Clone the git repo of Audiocraft and set version
WORKDIR /
RUN git clone https://github.com/rsxdalv/tts-generation-webui.git && \
    cd /tts-generation-webui && \
    git checkout ${TTS_COMMIT}

# Install the dependencies for Audiocraft
WORKDIR /tts-generation-webui
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install --no-cache-dir xformers==0.0.19 && \
    pip3 install -r requirements.txt && \
    pip3 install -r requirements_audiocraft.txt && \
    pip3 install -r requirements_bark_hubert_quantizer.txt && \
    pip3 install -r requirements_rvc.txt && \
    deactivate

# Copy configuration files
COPY config.json /tts-generation-webui/config.json
COPY .env /tts-generation-webui/.env

# Install Jupyter
RUN pip3 install -U --no-cache-dir jupyterlab \
        jupyterlab_widgets \
        ipykernel \
        ipywidgets \
        gdown

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html

# Set up the container startup script
WORKDIR /
COPY pre_start.sh start.sh fix_venv.sh ./
RUN chmod +x /start.sh && \
    chmod +x /pre_start.sh && \
    chmod +x /fix_venv.sh

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]