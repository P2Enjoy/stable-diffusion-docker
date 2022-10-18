# syntax=docker/dockerfile:1
      
############################################################################################################################################################################################
FROM nvidia/cuda:11.6.2-devel-ubuntu20.04 as CUDA

#tensorflow-cpu tensorflow-gpu intel-tensorflow intel-tensorflow-avx512
ARG TENSORFLOW="intel-tensorflow==2.9.1"
ARG TORCH_CUDA_ARCH_LIST="7.5+PTX"
ARG XFORMER_SHA="3633e1afc7bffbe61957f04e7bb1a742ee910ace"

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive 
ENV PIP_PREFER_BINARY=1 
ENV PIP_NO_CACHE_DIR=1
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV MAX_GCC_VERSION=10
ENV MAKEFLAGS="-j12" 
ENV FORCE_CUDA=1 
ENV NVCC_FLAGS="--use_fast_math -allow-unsupported-compiler" 

RUN <<EOF
#python
apt-get update
apt-get full-upgrade -y
apt-get install git curl -y
echo "
deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu focal main 
deb-src https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu focal main 
" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
apt-get update
apt-get install python3\.10-minimal python3\.10-venv libpython3\.10-dev libpython3\.10-stdlib -y
update-alternatives --install /usr/bin/python python $(which python3.10) 1
python --version
python -m ensurepip
update-alternatives --install /usr/bin/pip pip $(which pip3) 1
EOF

RUN <<EOF
#GCC
apt-get update
apt-get install gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
update-alternatives --install /usr/bin/gcc gcc $(which gcc-$MAX_GCC_VERSION) 1
update-alternatives --install /usr/bin/g++ g++ $(which g++-$MAX_GCC_VERSION) 1
apt-get autopurge -y
EOF

RUN <<EOF
#xformers sources
git clone https://github.com/facebookresearch/xformers.git /xformers
cd /xformers
git reset --hard ${XFORMER_SHA}
git submodule update --init --recursive
EOF

WORKDIR /xformers
RUN <<EOF
#xformers libs
python -m venv venv
source ./venv/bin/activate
pip install --upgrade pip
#/usr/bin/nvidia-smi
#export TORCH_CUDA_ARCH_LIST="$(/usr/bin/nvidia-smi --query-gpu=compute_cap --format=csv | tail -1)+PTX"
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST}"
pip install --prefer-binary --no-cache-dir ${TENSORFLOW}
pip install --prefer-binary --no-cache-dir setuptools
pip install --prefer-binary --no-cache-dir wheel
pip install --prefer-binary --no-cache-dir ninja
EOF

RUN <<EOF
#xformers pip
python -m venv venv
source ./venv/bin/activate
pip install --upgrade pip
pip install --prefer-binary --no-cache-dir -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu116
EOF

RUN <<EOF
#xformers build
python -m venv venv
source ./venv/bin/activate
pip install --upgrade pip
#-DXFORMERS_MEM_EFF_ATTENTION_DISABLE_BACKWARD
python setup.py build
EOF

RUN <<EOF
#xformers dist
python -m venv venv
source ./venv/bin/activate
pip install --upgrade pip
python setup.py bdist_wheel
EOF

COPY . /docker
RUN <<EOF
chmod +x /docker/deploy.sh
EOF

WORKDIR /docker
ENTRYPOINT ["/docker/deploy.sh"]
