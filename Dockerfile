ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
# No --system-site-packages used here because it creates issues with
# packages not being found.
RUN python3 -m venv /venv

# Clone the git repo of TTS Generation WebUI and set version
ARG TTS_COMMIT
RUN git clone https://github.com/rsxdalv/tts-generation-webui.git && \
    cd /tts-generation-webui && \
    git checkout ${TTS_COMMIT}

# Install the Python dependencies for TTS Generation WebUI
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /tts-generation-webui
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchaudio torchvision --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} && \
    pip3 install -r requirements.txt && \
    pip3 install -r requirements_audiocraft_only.txt --no-deps && \
    pip3 install -r requirements_audiocraft_deps.txt && \
    pip3 install -r requirements_bark_hubert_quantizer.txt && \
    pip3 install -r requirements_rvc.txt && \
    pip3 install hydra-core==1.3.2 && \
    pip3 install -r requirements_styletts2.txt && \
    pip3 install -r requirements_vall_e.txt && \
    pip3 install -r requirements_maha_tts.txt && \
    deactivate

# Install the NodeJS dependencies for the TTS Generation WebUI
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt -y install nodejs && \
    cd /tts-generation-webui/react-ui && \
    npm install && \
    npm run build

# Copy configuration files
COPY config.json /tts-generation-webui/config.json
COPY .env /tts-generation-webui/.env

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
