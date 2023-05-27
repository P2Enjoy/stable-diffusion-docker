# syntax=docker/dockerfile:1

############################################################################################################################################################################################
FROM alpine/git:2.36.2 as download

SHELL ["/bin/sh", "-ceuxo", "pipefail"]
ARG stableDiffusionV1_SHA
ARG stableDiffusionV2_SHA
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
RUN git clone https://github.com/P2Enjoy/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard ${codeFormer_SHA}
RUN git clone https://github.com/P2Enjoy/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard ${BLIP_SHA}
#RUN git clone https://github.com/P2Enjoy/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard ${latentDiffusion_SHA}
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
FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ARG PYTORCH_CUDA_ALLOC_CONF
ARG MAX_GCC_VERSION
ARG JAX
ARG TPU
ARG AUTO1111_SHA
ARG GFPGAN_SHA
ARG CLIP_SHA
ARG open_clip_SHA
ARG PIP_REPOSITORY
ARG TORCH_CUDA_ARCH_LIST
ARG DS_BUILD_OPS
ARG TRITON_VERSION
ARG DEEPSPEED_VERSION
ARG CUDNN_VERSION
ARG DEEPSPEED
ARG NVCC_FLAGS
ARG TORCH_COMMAND
ARG XFORMERS_COMMAND
ARG TENSORFLOW_COMMAND
ARG pyver

ENV pyver=${pyver}
ENV NVCC_FLAGS=${NVCC_FLAGS}
ENV TRITON_VERSION=${TRITON_VERSION}
ENV DEEPSPEED_VERSION=${DEEPSPEED_VERSION}
ENV CUDNN_VERSION=${CUDNN_VERSION}
ENV DEEPSPEED=${DEEPSPEED}
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
ENV DS_BUILD_OPS=${DS_BUILD_OPS}
ENV PIP_REPOSITORY=${PIP_REPOSITORY}
ENV TORCH_COMMAND=${TORCH_COMMAND}
ENV XFORMERS_COMMAND=${XFORMERS_COMMAND}
ENV TENSORFLOW_COMMAND=${TENSORFLOW_COMMAND}
ENV JAX=${JAX}
ENV TPU=${TPU}
ENV PYTORCH_CUDA_ALLOC_CONF=${PYTORCH_CUDA_ALLOC_CONF}
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV EXTENSIONSDIR=${ROOT}/custom_scripts
ENV REPODIR=${ROOT}/repositories
ENV WORKDIR=${REPODIR}/stable-diffusion
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV USE_MEMORY_EFFICIENT_ATTENTION=0
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

ENV RUNNER='echo Please specify the command line runner from the composer; ARGS: '
ENV CLI_ARGS=""
ENV RUN_ARGS=""

RUN <<EOF
# apt for general container dependencies
apt-get update 
apt-get install fonts-dejavu-core rsync git jq moreutils dos2unix gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
update-alternatives --install /usr/bin/gcc gcc $(which gcc-$MAX_GCC_VERSION) 1
update-alternatives --install /usr/bin/g++ g++ $(which g++-$MAX_GCC_VERSION) 1
apt-get full-upgrade -y
apt-get autopurge -y
EOF

RUN <<EOF
# apt for extensions/custom scripts
apt-get install tk potrace ffmpeg unzip gnupg2 curl libgl1-mesa-dev libegl1-mesa-dev libsm6 libxext6 libxrender-dev mesa-utils-extra libegl1-mesa-dev libgles2-mesa-dev libegl1-mesa libglfw3-dev libfontconfig1-dev wget xvfb dpkg -y
EOF

ENV CUDA_HOME=/usr/local/cuda
ENV CUDNN_PATH=/usr/local/lib/python${pyver}/site-packages/nvidia/cudnn
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/lib/python${pyver}/site-packages/tensorrt/:/usr/local/lib/python${pyver}/site-packages/nvidia/cudnn:$LD_LIBRARY_PATH
ENV PATH=$PATH:$CUDA_HOME/bin
RUN <<EOF
# cuda toolkit
wget https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.0-1_all.deb
dpkg -i cuda-keyring_1.0-1_all.deb
echo "
# Contrib debian source
deb http://deb.debian.org/debian bullseye main contrib
" >> /etc/apt/sources.list
apt-get update
apt-get -y install cuda
EOF

COPY ./scripts/install-container-dep.sh /docker/
RUN <<EOF
# cuda toolkit + tensorflow
/bin/bash /docker/install-container-dep.sh install nvidia-tensorrt
ln -s /usr/local/lib/python${pyver}/site-packages/tensorrt/libnvinfer.so.8 /usr/local/lib/python${pyver}/site-packages/tensorrt/libnvinfer.so.7
ln -s /usr/local/lib/python${pyver}/site-packages/tensorrt/libnvinfer_plugin.so.8 /usr/local/lib/python${pyver}/site-packages/tensorrt/libnvinfer_plugin.so.7

/bin/bash /docker/install-container-dep.sh nvidia-cudnn-cu11==${CUDNN_VERSION}
EOF


############################################################################################################################################################################################

RUN <<EOF
git clone https://github.com/P2Enjoy/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
git reset --hard ${AUTO1111_SHA}
dos2unix ${ROOT}/**/*
python -m ensurepip
EOF

COPY --from=download /git/ ${ROOT}
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate

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

RUN <<EOF
# transformers
#/bin/bash /docker/install-container-dep.sh transformers>=4.24 diffusers #invisible-watermark
EOF

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

#################################################################################################################################################

RUN <<EOF
# webui
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed -r ${ROOT}/requirements.txt
EOF
#################################################################################################################################################

#ENV TPU_LIBRARY_PATH="/stable-diffusion-webui/venv/lib/python3.10/site-packages/libtpu/"
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
COPY ./scripts /docker/

RUN <<EOF
python3 /docker/info.py ${ROOT}/modules/ui.py
chmod +x /docker/{run,mount,debug}.sh
sed -i 's/os.rename(tmpdir, target_dir)/shutil.move(tmpdir,target_dir)/' ${ROOT}/modules/ui_extensions.py
sed -i 's/in_app_dir = .*/in_app_dir = True/g' /usr/local/lib/python${pyver}/site-packages/gradio/routes.py
EOF

WORKDIR ${ROOT}
EXPOSE 7860
ENTRYPOINT $RUNNER $RUN_ARGS --ckpt-dir ${ROOT}/models/Stable-diffusion $CLI_ARGS

