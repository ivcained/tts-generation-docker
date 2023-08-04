#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/

# Sync TTS Web UI to workspace to support Network volumes
echo "Syncing TTS Web UI to workspace, please wait..."
rsync -au /tts-generation-webui/ /workspace/tts-generation-webui/

# Fix the venv to make it work from /workspace
echo "Fixing venv..."
/fix_venv.sh /venv /workspace/venv

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/tts-generation-webui"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   ./python3 app.py --listen 0.0.0.0 --server_port 3001"
else
    mkdir -p /workspace/logs
    echo "Starting TTS Generation Web UI"
    export HF_HOME="/workspace"
    source /workspace/venv/bin/activate
    cd /workspace/tts-generation-webui
    nohup python3 server.py > /workspace/logs/tts.log 2>&1 &
    echo "TTS Generation Web UI started"
    echo "Log file: /workspace/logs/tts.log"
    deactivate
fi

echo "All services have been started"