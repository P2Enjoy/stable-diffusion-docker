# syntax=docker/dockerfile:1
ARG pyimage
ARG pyver

############################################################################################################################################################################################
FROM alpine/git:2.36.2 as download

SHELL ["/bin/sh", "-ceuxo", "pipefail"]
ARG stableDiffusionV1_SHA
ARG stableDiffusionV2_SHA
ARG stableDiffusionXL_SHA
ARG codeFormer_SHA
ARG BLIP_SHA
ARG latentDiffusion_SHA
ARG tamingTransformers_SHA
ARG kDiffusion_SHA
ARG clip_interrogator_SHA
ARG MiDas_SHA

WORKDIR /git
RUN git clone https://github.com/P2Enjoy/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard ${stableDiffusionV1_SHA}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-v2.git repositories/stable-diffusion-stability-ai && cd repositories/stable-diffusion-stability-ai && git reset --hard ${stableDiffusionV2_SHA}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-xl.git repositories/generative-models && cd repositories/generative-models && git reset --hard ${stableDiffusionXL_SHA}
RUN git clone https://github.com/P2Enjoy/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard ${codeFormer_SHA}
RUN git clone https://github.com/P2Enjoy/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard ${BLIP_SHA}
RUN git clone https://github.com/P2Enjoy/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard ${latentDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/k-diffusion.git repositories/k-diffusion && cd repositories/k-diffusion && git reset --hard ${kDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/clip-interrogator.git repositories/clip-interrogator && cd repositories/clip-interrogator && git reset --hard ${clip_interrogator_SHA}
RUN git clone https://github.com/P2Enjoy/MiDaS.git repositories/midas && cd repositories/midas && git reset --hard ${MiDas_SHA}
RUN git clone https://github.com/compphoto/BoostingMonocularDepth.git repositories/BoostingMonocularDepth

RUN <<EOF
# because taming-transformers is huge
git config --global http.postBuffer 1048576000
git clone https://github.com/P2Enjoy/taming-transformers.git repositories/taming-transformers
cd repositories/taming-transformers
git reset --hard ${tamingTransformers_SHA}
rm -rf data assets
EOF

RUN <<EOF
#dos2unix
apk add --no-cache dos2unix
dos2unix /git/repositories/**/*
EOF

############################################################################################################################################################################################
FROM $pyimage as base

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ARG TORCH_CUDA_ARCH_LIST
ARG CUDNN_VERSION
ARG CUDA_KEYRING
ARG NVCC_FLAGS

ARG PIP_REPOSITORY

ENV NVCC_FLAGS=${NVCC_FLAGS}
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_REPOSITORY=${PIP_REPOSITORY}
ENV PIP_NO_CACHE_DIR=1
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN <<EOF
# apt for general container dependencies
apt-get update 
apt-get install fonts-dejavu-core rsync git jq moreutils dos2unix gcc g++ -y
apt-get full-upgrade -y
apt-get autopurge -y
EOF

RUN <<EOF
# apt for extensions/custom scripts
apt-get install tk potrace ffmpeg unzip gnupg2 curl libgl1-mesa-dev libegl1-mesa-dev libsm6 libxext6 libxrender-dev mesa-utils-extra libegl1-mesa-dev libgles2-mesa-dev libegl1-mesa libglfw3-dev libfontconfig1-dev wget xvfb dpkg -y
apt-get install procps -y
EOF

RUN <<EOF
# apt configurations
export VERSION_CODENAME="$(cat /etc/*-release | fgrep VERSION_CODENAME | cut -d'=' -f2)"
export VERSION_ID="$(cat /etc/*-release | fgrep VERSION_ID | cut -d'=' -f2)"
echo "

# Full debian sources
deb http://deb.debian.org/debian $VERSION_CODENAME main contrib
" >> /etc/apt/sources.list
apt-get update
EOF

RUN <<EOF
# cuda configurations
wget -O cuda-keyring.deb $CUDA_KEYRING
apt-get install -f ./cuda-keyring.deb -y
apt-get update
EOF

COPY ./scripts/install-container-dep.sh /docker/
RUN <<EOF
# cuda cudnn + cutlass + tensorrt
/bin/bash /docker/install-container-dep.sh nvidia-cudnn-cu11==${CUDNN_VERSION}
/bin/bash /docker/install-container-dep.sh cutlass
/bin/bash /docker/install-container-dep.sh install nvidia-tensorrt
EOF

############################################################################################################################################################################################
FROM base as sd

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ARG GFPGAN_SHA
ARG CLIP_SHA
ARG open_clip_SHA

ARG TORCH_COMMAND
ARG XFORMERS_COMMAND
ARG TENSORFLOW_COMMAND
ARG DS_BUILD_OPS

ARG DEEPSPEED
ARG DEEPSPEED_VERSION
ARG TORCH_CUDA_ARCH_LIST
ARG TRITON_VERSION
ARG JAX
ARG TPU
ARG pyver

ENV pyver=${pyver}

ENV ROOT=/stable-diffusion-webui
ENV EXTENSIONSDIR=${ROOT}/custom_scripts
ENV REPODIR=${ROOT}/repositories

ENV CUDART_PATH=/venv/lib/python${pyver}/site-packages/nvidia/cuda_runtime
ENV CUDNN_PATH=/venv/lib/python${pyver}/site-packages/nvidia/cudnn
ENV TENSORRT_PATH=/venv/lib/python${pyver}/site-packages/tensorrt
ENV LD_LIBRARY_PATH=$TENSORRT_PATH:$CUDNN_PATH/lib:$CUDART_PATH/lib:$LD_LIBRARY_PATH

RUN <<EOF
git clone https://github.com/P2Enjoy/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
python -m ensurepip
EOF

WORKDIR ${ROOT}

RUN <<EOF
# Build requirements
/bin/bash /docker/install-container-dep.sh setuptools
/bin/bash /docker/install-container-dep.sh wheel
/bin/bash /docker/install-container-dep.sh ninja
/bin/bash /docker/install-container-dep.sh pyngrok
EOF

#COPY ./data/*.whl /docker/
RUN <<EOF
# tensorflow
$TENSORFLOW_COMMAND
EOF

RUN <<EOF
# torch, torchvision, torchaudio
$TORCH_COMMAND
EOF

RUN <<EOF
# xformers
$XFORMERS_COMMAND
EOF

RUN <<EOF
# transformers
#/bin/bash /docker/install-container-dep.sh transformers>=4.24 diffusers #invisible-watermark
EOF

COPY --from=download /git/ ${ROOT}

RUN <<EOF
# k-diffusion
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed -r ${ROOT}/repositories/k-diffusion/requirements.txt
EOF

RUN <<EOF
# Codeformer
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed -r ${ROOT}/repositories/CodeFormer/requirements.txt
EOF

RUN <<EOF
# GFPGAN
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed git+https://github.com/P2Enjoy/GFPGAN.git@${GFPGAN_SHA}
EOF

RUN <<EOF
# CLIP
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed git+https://github.com/P2Enjoy/CLIP.git@${CLIP_SHA}
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed git+https://github.com/P2Enjoy/open_clip.git@${open_clip_SHA}
EOF

RUN <<EOF
# cutlass
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed cutlass
EOF

RUN <<EOF
# deepspeed
/bin/bash /docker/install-container-dep.sh triton==${TRITON_VERSION}
if [[ ! -z "${DEEPSPEED}" ]] && [[ "${DEEPSPEED}" == "True" ]]
then
  export NVCC_FLAGS=${NVCC_FLAGS}
  export TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
  export DS_BUILD_OPS=${DS_BUILD_OPS}
  export DS_BUILD_SPARSE_ATTN=0 
  /bin/bash /docker/install-container-dep.sh deepspeed==${DEEPSPEED_VERSION}
fi
EOF

ENV TPU_LIBRARY_PATH="/stable-diffusion-webui/venv/lib/python${pyver}/site-packages/libtpu/"
RUN <<EOF
#jax/tpu
if [[ ! -z "${TPU}" ]] && [[ "${TPU}" == "True" ]]
then
  /bin/bash /docker/install-container-dep.sh tpu -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
fi
if [[ ! -z "${JAX}" ]] && [[ "${JAX}" == "True" ]]
then
  /bin/bash /docker/install-container-dep.sh "jax[cuda11_cudnn805]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
fi
EOF

#################################################################################################################################################
FROM sd as sdcuda

ARG CUDA_VERSION
ARG CUDA_DRIVERS

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$PATH:$CUDA_HOME/bin
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib:$LD_LIBRARY_PATH

RUN <<EOF
# Hotfix for libnvinfer7
ln -s $TENSORRT_PATH/libnvinfer.so.8 $TENSORRT_PATH/libnvinfer.so.7
ln -s $TENSORRT_PATH/libnvinfer_plugin.so.8 $TENSORRT_PATH/libnvinfer_plugin.so.7
EOF

RUN <<EOF
# cuda driver update
apt-get update
apt-get -y install $CUDA_VERSION $CUDA_DRIVERS
EOF

#################################################################################################################################################
FROM sdcuda as webui

ARG AUTO1111_SHA

ENV PYTORCH_CUDA_ALLOC_CONF=${PYTORCH_CUDA_ALLOC_CONF}
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV USE_MEMORY_EFFICIENT_ATTENTION=0
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV RUNNER='echo Please specify the command line runner from the composer; ARGS: '
ENV CLI_ARGS=""
ENV RUN_ARGS=""

RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate

WORKDIR ${ROOT}

RUN <<EOF
# webui update
git fetch --all
git reset --hard ${AUTO1111_SHA}
dos2unix ${ROOT}/**/*

/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed -r ${ROOT}/requirements_versions.txt
EOF

#################################################################################################################################################
COPY ./scripts /docker/

RUN <<EOF
python3 /docker/info.py ${ROOT}/modules/ui.py
chmod +x /docker/{run,mount,debug}.sh
sed -i 's/os.rename(tmpdir, target_dir)/shutil.move(tmpdir,target_dir)/' ${ROOT}/modules/ui_extensions.py
#sed -i 's/in_app_dir = .*/in_app_dir = True/g' /usr/local/lib/python${pyver}/site-packages/gradio/routes.py
EOF

WORKDIR ${ROOT}
EXPOSE 7860
ENTRYPOINT $RUNNER $RUN_ARGS --ckpt-dir ${ROOT}/models/Stable-diffusion $CLI_ARGS

