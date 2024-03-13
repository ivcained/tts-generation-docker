variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "tts-generation"
}

variable "RELEASE" {
    default = "2.0.9"
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
        XFORMERS_VERSION = "0.0.19+cu${CU_VERSION}"
        TTS_COMMIT = "b8549c3d16f8b3545d72ef87f2f93a21e24e32c1"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/tts-generation-webui"
    }
}
