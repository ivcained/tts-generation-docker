#!/usr/bin/env bash

mkdir -p /workspace/logs
echo "Starting TTS Generation Web UI"
export HF_HOME="/workspace"
# Set port for the React UI
export PORT=3006
VENV_PATH=$(cat /workspace/SUPIR/venv_path)
source ${VENV_PATH}/bin/activate
cd /workspace/tts-generation-webui
nohup python3 server.py > /workspace/logs/tts.log 2>&1 &
echo "TTS Generation Web UI started"
echo "Log file: /workspace/logs/tts.log"
deactivate
