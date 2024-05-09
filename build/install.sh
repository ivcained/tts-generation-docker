#!/usr/bin/env bash
# Create and use the Python venv
# No --system-site-packages used here because it creates issues with
# packages not being found.
python3 -m venv /venv

# Clone the git repo of TTS Generation WebUI and set version
git clone https://github.com/rsxdalv/tts-generation-webui.git
cd /tts-generation-webui
git checkout ${TTS_COMMIT}

# Install the Python dependencies for TTS Generation WebUI
source /venv/bin/activate
pip3 install --upgrade pip
pip3 install --no-cache-dir torch==${TORCH_VERSION} torchaudio torchvision --index-url ${INDEX_URL}
pip3 install --no-cache-dir xformers==${XFORMERS_VERSION}
pip3 install -r requirements.txt
pip3 install -r requirements_audiocraft_only.txt --no-deps
pip3 install -r requirements_audiocraft_deps.txt
pip3 install -r requirements_bark_hubert_quantizer.txt
pip3 install -r requirements_rvc.txt
pip3 install hydra-core==1.3.2
pip3 install -r requirements_styletts2.txt
pip3 install -r requirements_vall_e.txt
pip3 install -r requirements_maha_tts.txt
deactivate

# Install the NodeJS dependencies for the TTS Generation WebUI
apt -y purge nodejs libnode*
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt -y install nodejs
cd /tts-generation-webui/react-ui
npm install
npm run build
