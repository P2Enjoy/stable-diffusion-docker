# syntax=docker/dockerfile:1
ARG XFORMER_SHA=HEAD
FROM nvidia/cuda:11.6-devel-ubuntu20.04 as CUDA

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1

#python
RUN <<EOF
apt-get update
apt-get install git curl -y
echo "
deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu focal main 
deb-src https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu focal main 
" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
apt-get update

apt-get install python3\.10-minimal python3\.10-venv -y
apt-get purge python3
update-alternatives --install /usr/bin/python python $(which python3.10) 1
python --version
python -m ensurepip --upgrade
EOF

#xformers sources
RUN <<EOF
git clone https://github.com/facebookresearch/xformers.git /xformers
cd /xformers
git reset --hard ${XFORMER_SHA}
git submodule update --init --recursive
EOF

#python ML
RUN <<EOF
cd /xformers
pip install --prefer-binary --no-cache-dir torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
EOF

#xformers build
RUN <<EOF
cd /xformers
pip install --prefer-binary --no-cache-dir setuptools==49.6.0
pip install --prefer-binary --no-cache-dir -r requirements.txt
pip install --prefer-binary --no-cache-dir wheel
pip install --prefer-binary --no-cache-dir ninja
export TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
export MAKEFLAGS="-j$(nproc)" FORCE_CUDA=1 NVCC_FLAGS="--use_fast_math -allow-unsupported-compiler" #-DXFORMERS_MEM_EFF_ATTENTION_DISABLE_BACKWARD
python setup.py build
python setup.py bdist_wheel
EOF

############################################################################################################################################################################################
ARG stableDiffusion_SHA=HEAD
ARG codeFormer_SHA=HEAD
ARG BLIP_SHA=HEAD
ARG latentDiffusion_SHA=HEAD
ARG tamingTransformers_SHA=HEAD
ARG kDiffusion_SHA=HEAD
FROM alpine/git:2.36.2 as download

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

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
ARG AUTO1111_SHA=HEAD
ARG TencentARC_SHA=HEAD
ARG CLIP_SHA=HEAD
ARG DeepDanbooru_SHA=HEAD
FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV WORKDIR=/stable-diffusion-webui/repositories/stable-diffusion
  
RUN pip install --prefer-binary --no-cache-dir torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116

RUN apt-get update && apt-get install fonts-dejavu-core rsync git jq moreutils -y && apt-get clean

RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
git reset --hard ${SHA}
python -m venv venv
source ${ROOT}/venv/bin/activate
EOF

COPY --from=download /git/ ${ROOT}
RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt
RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir opencv-python-headless
RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir git+https://github.com/TencentARC/GFPGAN.git@${TencentARC_SHA} 
RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir git+https://github.com/openai/CLIP.git@${CLIP_SHA}
RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir pyngrok 

COPY --from=CUDA  /xformers/dist/xformers*.whl ${ROOT}/repositories/

RUN <<EOF
#webui
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install setuptools==49.6.0
pip install wheel
pip install ninja
pip install ${ROOT}/repositories/*.whl
pip install -r ${ROOT}/requirements_versions.txt
pip install -r ${ROOT}/requirements.txt
EOF

RUN source ${ROOT}/venv/bin/activate && pip install --prefer-binary --no-cache-dir git+https://github.com/KichangKim/DeepDanbooru.git@${DeepDanbooru_SHA}#egg=deepdanbooru[tensorflow] tensorflow==2.10.0 tensorflow-io==0.27.0

COPY . /docker
RUN <<EOF
source ${ROOT}/venv/bin/activate
chmod +x /docker/mount.sh && python3 /docker/info.py ${ROOT}/modules/ui.py
EOF

ENV CLI_ARGS=""
WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout/stderr
CMD /docker/mount.sh && \
  source ../../venv/bin/activate && python3 -u ../../webui.py --listen --port 7860 --ckpt-dir ${ROOT}/models/Stable-diffusion ${CLI_ARGS}
