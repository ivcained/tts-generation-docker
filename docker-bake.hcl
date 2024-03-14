variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "tts-generation"
}

variable "RELEASE" {
    default = "2.0.10"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.0.0+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.19"
        TTS_COMMIT = "c71e1a796f41af17392b64d5c70926288c238231"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/tts-generation-webui"
    }
}
