# syntax=docker/dockerfile:1

############################################################################################################################################################################################
FROM alpine/git:2.36.2 as download

ARG stableDiffusion_SHA="69ae4b35e0a0f6ee1af8bb9a5d0016ccb27e36dc"
ARG codeFormer_SHA="fa547b7aba3ef0a2b1b8db9956e6dba2984de218"
ARG BLIP_SHA="3a29b7410476bf5f2ba0955827390eb6ea1f4f9d"
ARG latentDiffusion_SHA="abf33e7002d59d9085081bce93ec798dcabd49af"
ARG tamingTransformers_SHA="24268930bf1dce879235a7fddd0b2355b84d7ea6"
ARG kDiffusion_SHA="f4e99857772fc3a126ba886aadf795a332774878"

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

WORKDIR /git
RUN git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard ${stableDiffusion_SHA}
RUN git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard ${codeFormer_SHA}
RUN git clone https://github.com/salesforce/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard ${BLIP_SHA}
RUN git clone https://github.com/Hafiidz/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard ${latentDiffusion_SHA}
RUN <<EOF
# because taming-transformers is huge
git config --global http.postBuffer 1048576000
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
cd repositories/taming-transformers
git reset --hard ${tamingTransformers_SHA}
rm -rf data assets
EOF
RUN git clone https://github.com/crowsonkb/k-diffusion.git repositories/k-diffusion && cd repositories/k-diffusion && git reset --hard ${kDiffusion_SHA}

############################################################################################################################################################################################
FROM python:3.10-slim

#tensorflow-cpu tensorflow-gpu intel-tensorflow intel-tensorflow-avx512
ARG TENSORFLOW="intel-tensorflow==2.9.1"
ARG PIP_REPOSITORY="https://download.pytorch.org/whl/cu116"
ARG AUTO1111_SHA="c57919ea2a8e4a23a05d21f28928e08bbf34c59e"
ARG GFPGAN_SHA="2eac2033893ca7f427f4035d80fe95b92649ac56"
ARG CLIP_SHA="d50d76daa670286dd6cacf3bcd80b5e4823fc8e1"
ARG DeepDanbooru_SHA="12e3a13d1d0369f5008376907aa752188772dfe1"

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV WORKDIR=/stable-diffusion-webui/repositories/stable-diffusion
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV MAX_GCC_VERSION=10

RUN apt-get update && apt-get install fonts-dejavu-core rsync git jq moreutils -y && apt-get full-upgrade -y && apt-get autopurge -y

#GCC
RUN <<EOF
apt-get install gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
EOF

RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
git reset --hard ${AUTO1111_SHA}
python -m venv venv
source ${ROOT}/venv/bin/activate
python -m ensurepip
EOF

COPY --from=download /git/ ${ROOT}
RUN <<EOF
# Build requirements
source ${ROOT}/venv/bin/activate
pip install --upgrade pip

pip install --extra-index-url ${PIP_REPOSITORY} setuptools
pip install --extra-index-url ${PIP_REPOSITORY} wheel
pip install --extra-index-url ${PIP_REPOSITORY} ninja

pip install --extra-index-url ${PIP_REPOSITORY} ${TENSORFLOW} torch==1.12.1+cu116 torchvision==0.13.1+cu116

pip install --extra-index-url ${PIP_REPOSITORY} pyngrok
EOF

RUN <<EOF
# transformers.git
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} transformers==4.19.2 diffusers invisible-watermark
EOF

RUN <<EOF
# k-diffusion
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/repositories/k-diffusion/requirements.txt
EOF

RUN <<EOF
# Codeformer
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/repositories/CodeFormer/requirements.txt
EOF

#################################################################################################################################################

RUN <<EOF
# webui
cd ${ROOT}
source ${ROOT}/venv/bin/activate
#pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/requirements_versions.txt
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/requirements.txt
EOF

RUN <<EOF
# opencv
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} opencv-python-headless
EOF

RUN <<EOF
# numpy
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} -U numpy
EOF

#################################################################################################################################################
RUN <<EOF
# GFPGAN
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/TencentARC/GFPGAN.git@${GFPGAN_SHA}
EOF

RUN <<EOF
# CLIP
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/openai/CLIP.git@${CLIP_SHA}
EOF

COPY ./data/xformers*.whl /docker/
RUN <<EOF
# xformers
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} /docker/xformers*.whl
EOF

RUN <<EOF
# DeepDanbooru
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/KichangKim/DeepDanbooru.git@${DeepDanbooru_SHA}#egg=deepdanbooru[${TENSORFLOW}] ${TENSORFLOW}==2.10.0 tensorflow-io==0.27.0
EOF
#################################################################################################################################################

COPY ./scripts /docker/
RUN <<EOF
source ${ROOT}/venv/bin/activate
chmod +x /docker/{run,mount}.sh && python3 /docker/info.py ${ROOT}/modules/ui.py
EOF

ENV CLI_ARGS=""
WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout/stderr
CMD /docker/run.sh -u ../../webui.py --listen --port 7860 --ckpt-dir ${ROOT}/models/Stable-diffusion ${CLI_ARGS}
