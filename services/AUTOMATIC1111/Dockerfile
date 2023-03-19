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
ARG TORCH_COMMAND
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
ARG DEEPSPEED
ARG NVCC_FLAGS

ENV NVCC_FLAGS=${NVCC_FLAGS}
ENV TRITON_VERSION=${TRITON_VERSION}
ENV DEEPSPEED_VERSION=${DEEPSPEED_VERSION}
ENV DEEPSPEED=${DEEPSPEED}
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
ENV DS_BUILD_OPS=${DS_BUILD_OPS}
ENV PIP_REPOSITORY=${PIP_REPOSITORY}
ENV TORCH_COMMAND=${TORCH_COMMAND}
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
apt-get install tk potrace ffmpeg unzip gnupg2 curl libgl1-mesa-dev libegl1-mesa-dev libsm6 libxext6 libxrender-dev mesa-utils-extra libegl1-mesa-dev libgles2-mesa-dev libegl1-mesa libglfw3-dev libfontconfig1-dev wget xvfb -y
EOF

COPY ./data/libs/*.deb /docker/
RUN <<EOF
# cuda
#. /etc/os-release
ID="ubuntu"
VERSION_ID="20.04"
curl -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/cuda-${ID}${VERSION_ID/\./}.pin
echo "
deb https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64 /
" > /etc/apt/sources.list.d/cuda.list

VERSION_ID="18.04"
echo "
deb https://developer.download.nvidia.com/compute/machine-learning/repos/${ID}${VERSION_ID/\./}/x86_64 /
" > /etc/apt/sources.list.d/tensorRT.list

apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/7fa2af80.pub
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/3bf863cc.pub

apt-get update
apt install /docker/*.deb -y
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

COPY ./scripts/install-container-dep.sh ./data/*-requirements.txt /docker/
RUN <<EOF
# Build requirements
/bin/bash /docker/install-container-dep.sh setuptools
/bin/bash /docker/install-container-dep.sh wheel
/bin/bash /docker/install-container-dep.sh ninja
/bin/bash /docker/install-container-dep.sh pyngrok
EOF

COPY ./data/*.whl /docker/
RUN <<EOF
# tensorflow, torch, torchvision, torchaudio
$TORCH_COMMAND
EOF

RUN <<EOF
# xformers
cd ${ROOT}
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed  /docker/xformers-*.whl
EOF

RUN <<EOF
# cutlass
cd ${ROOT}
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed cutlass
EOF

RUN <<EOF
# deepspeed
cd ${ROOT}
pip install triton==${TRITON_VERSION}
[[ ! -z "${DEEPSPEED}" ]] && [ "${DEEPSPEED}"="True" ] && NVCC_FLAGS=${NVCC_FLAGS} TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} DS_BUILD_OPS=${DS_BUILD_OPS} DS_BUILD_SPARSE_ATTN=0 pip install deepspeed==${DEEPSPEED_VERSION}
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
cd ${ROOT}
if [ -f "/docker/webui-requirements.txt" ]; 
then
  pip install --extra-index-url ${PIP_REPOSITORY} -r /docker/webui-requirements.txt
else
  /bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed -r ${ROOT}/requirements.txt
fi;
EOF

RUN <<EOF
# extensions
cd ${ROOT}
if [ -f "/docker/extension-requirements.txt" ]; 
then
  pip install --extra-index-url ${PIP_REPOSITORY} -r /docker/extension-requirements.txt
fi;
EOF
#################################################################################################################################################

#ENV TPU_LIBRARY_PATH="/stable-diffusion-webui/venv/lib/python3.10/site-packages/libtpu/"
RUN <<EOF
#jax/tpu
[[ ! -z "${TPU}" ]] && [ "${TPU}"="True" ] && pip install tpu -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
[[ ! -z "${JAX}" ]] && [ "${JAX}"="True" ] && pip install "jax[cuda11_cudnn805]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
EOF

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda-11.2/targets/x86_64-linux/lib/:/usr/local/cuda-11.1/targets/x86_64-linux/lib/:/usr/local/cuda-11.0/targets/x86_64-linux/lib"
RUN <<EOF
#fix LDCONFIG
ldconfig
EOF

#################################################################################################################################################
COPY ./scripts /docker/

RUN <<EOF
python3 /docker/info.py ${ROOT}/modules/ui.py
chmod +x /docker/{run,mount,debug}.sh
sed -i 's/os.rename(tmpdir, target_dir)/shutil.move(tmpdir,target_dir)/' ${ROOT}/modules/ui_extensions.py
sed -i 's/in_app_dir = .*/in_app_dir = True/g' /usr/local/lib/python3.10/site-packages/gradio/routes.py
EOF

WORKDIR ${ROOT}
EXPOSE 7860
ENTRYPOINT $RUNNER $RUN_ARGS --ckpt-dir ${ROOT}/models/Stable-diffusion $CLI_ARGS

