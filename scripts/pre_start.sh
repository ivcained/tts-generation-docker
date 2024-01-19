#!/usr/bin/env bash

export PYTHONUNBUFFERED=1

echo "Template version: ${TEMPLATE_VERSION}"

if [[ -e "/workspace/template_version" ]]; then
    EXISTING_VERSION=$(cat /workspace/template_version)
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync venv to workspace to support Network volumes
    echo "Syncing venv to workspace, please wait..."
    rsync --remove-source-files -rlptDu /venv/ /workspace/venv/

    # Sync TTS Web UI to workspace to support Network volumes
    echo "Syncing TTS Web UI to workspace, please wait..."
    rsync --remove-source-files -rlptDu /tts-generation-webui/ /workspace/tts-generation-webui/
}

fix_venvs() {
    # Fix the venv to make it work from /workspace
    echo "Fixing venv..."
    /fix_venv.sh /venv /workspace/venv

    echo "${TEMPLATE_VERSION}" > /workspace/template_version
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs

        # Create directories
        mkdir -p /workspace/logs /workspace/tmp
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
fi

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/tts-generation-webui"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   ./python3 server.py"
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
