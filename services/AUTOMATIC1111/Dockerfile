# syntax=docker/dockerfile:1

############################################################################################################################################################################################
FROM alpine/git:2.36.2 as download

ARG stableDiffusion_SHA="a7e3c9820e064da54bdc97abe143caaf1a06b751"	#https://github.com/P2Enjoy/stable-diffusion.git
ARG codeFormer_SHA="8e5f81be41f283942b4346fef87ca1fad2cb889d"		#https://github.com/P2Enjoy/CodeFormer.git
ARG BLIP_SHA="3a29b7410476bf5f2ba0955827390eb6ea1f4f9d"			#https://github.com/P2Enjoy/BLIP.git
ARG latentDiffusion_SHA="abf33e7002d59d9085081bce93ec798dcabd49af"	#https://github.com/P2Enjoy/latent-diffusion.git
ARG tamingTransformers_SHA="24268930bf1dce879235a7fddd0b2355b84d7ea6"	#https://github.com/P2Enjoy/taming-transformers.git
ARG kDiffusion_SHA="5b3af030dd83e0297272d861c19477735d0317ec"		#https://github.com/P2Enjoy/k-diffusion.git
ARG clip_interrogator_SHA="55c922a48a7d352847fdd9840b8a791271dd0569"	#https://github.com/P2Enjoy/clip-interrogator.git

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

WORKDIR /git
RUN git clone https://github.com/P2Enjoy/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard ${stableDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard ${codeFormer_SHA}
RUN git clone https://github.com/P2Enjoy/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard ${BLIP_SHA}
#RUN git clone https://github.com/P2Enjoy/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard ${latentDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/k-diffusion.git repositories/k-diffusion && cd repositories/k-diffusion && git reset --hard ${kDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/clip-interrogator.git repositories/clip-interrogator && cd repositories/clip-interrogator && git reset --hard ${clip_interrogator_SHA}
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

#tensorflow-cpu tensorflow-gpu intel-tensorflow intel-tensorflow-avx512
ARG PIP_REPOSITORY="https://download.pytorch.org/whl/cu116"

ARG AUTO1111_SHA="1f389a43c0c9b9ec9b952147bc96a820766ba9bd"		#https://github.com/P2Enjoy/stable-diffusion-webui.git
ARG GFPGAN_SHA="2eac2033893ca7f427f4035d80fe95b92649ac56"		#https://github.com/P2Enjoy/GFPGAN.git
ARG CLIP_SHA="d50d76daa670286dd6cacf3bcd80b5e4823fc8e1"			#https://github.com/P2Enjoy/CLIP.git

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV EXTENSIONSDIR=${ROOT}/custom_scripts
ENV REPODIR=${ROOT}/repositories
ENV WORKDIR=${REPODIR}/stable-diffusion
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV USE_MEMORY_EFFICIENT_ATTENTION=0
ENV MAX_GCC_VERSION=10
ENV RUN_ARGS='ECHO Please specify the command line runner from the composer'

RUN apt-get update && apt-get install fonts-dejavu-core rsync git jq moreutils dos2unix -y && apt-get full-upgrade -y && apt-get autopurge -y

#GCC
RUN <<EOF
apt-get install gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
update-alternatives --install /usr/bin/gcc gcc $(which gcc-$MAX_GCC_VERSION) 1
update-alternatives --install /usr/bin/g++ g++ $(which g++-$MAX_GCC_VERSION) 1
EOF

RUN <<EOF
git clone https://github.com/P2Enjoy/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
git reset --hard ${AUTO1111_SHA}
dos2unix ${ROOT}/**/*
#python -m venv venv
#source ${ROOT}/venv/bin/activate
python -m ensurepip
EOF

COPY --from=download /git/ ${ROOT}

RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate

RUN <<EOF
# Build requirements
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip

pip install --extra-index-url ${PIP_REPOSITORY} setuptools
pip install --extra-index-url ${PIP_REPOSITORY} wheel
pip install --extra-index-url ${PIP_REPOSITORY} ninja
pip install --extra-index-url ${PIP_REPOSITORY} pyngrok
EOF

COPY ./data/*.whl /docker/
RUN <<EOF
# tensorflow, torch, torchvision
cd ${ROOT}
#source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} /docker/tensorflow-*.whl /docker/torch-*.whl /docker/torchvision-*.whl
EOF

RUN <<EOF
# transformers.git
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} transformers==4.21.0 diffusers #invisible-watermark
EOF

RUN <<EOF
# k-diffusion
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/repositories/k-diffusion/requirements.txt
EOF

RUN <<EOF
# Codeformer
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/repositories/CodeFormer/requirements.txt
EOF

#################################################################################################################################################
RUN <<EOF
# webui
cd ${ROOT}
#source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} -r ${ROOT}/requirements.txt
EOF

RUN <<EOF
# opencv
cd ${ROOT}
#source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} opencv-python-headless
EOF

RUN <<EOF
# numpy
cd ${ROOT}
#source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} -U numpy
EOF

#################################################################################################################################################
RUN <<EOF
# GFPGAN
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/P2Enjoy/GFPGAN.git@${GFPGAN_SHA}
EOF

RUN <<EOF
# CLIP
#source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/P2Enjoy/CLIP.git@${CLIP_SHA}
EOF

COPY ./data/xformers-*.whl /docker/
RUN <<EOF
# xformers
cd ${ROOT}
#source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} /docker/xformers-*.whl
#pip install --extra-index-url ${PIP_REPOSITORY} cutlass
EOF

#################################################################################################################################################
RUN <<EOF
#gnupg
apt-get update
apt-get install gnupg2 curl -y
EOF

COPY ./data/libs/*.deb /docker/
RUN <<EOF
#cuda
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

#ENV TPU_LIBRARY_PATH="/stable-diffusion-webui/venv/lib/python3.10/site-packages/libtpu/"
RUN <<EOF
#jax/tpu
#source ${ROOT}/venv/bin/activate
#pip install tpu -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
pip install "jax[cuda11_cudnn805]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
EOF

ENV LD_LIBRARY_PATH="${TPU_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/local/cuda-11.2/targets/x86_64-linux/lib/:/usr/local/cuda-11.1/targets/x86_64-linux/lib/:/usr/local/cuda-11.0/targets/x86_64-linux/lib"
RUN <<EOF
#fix LDCONFIG
ldconfig
EOF

###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT##
RUN <<EOF
# apt for extensions/custom scripts
apt-get install tk potrace ffmpeg unzip -y #libgtk2.0-dev
EOF

###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS

RUN <<EOF
#extensions
#source ${ROOT}/venv/bin/activate
pip install "torchsde"
pip install "spacy"
python3 -m spacy download en_core_web_sm
EOF

#################################################################################################################################################
COPY ./scripts /docker/

RUN <<EOF
#source ${ROOT}/venv/bin/activate
python3 /docker/info.py ${ROOT}/modules/ui.py

chmod +x /docker/{run,mount,debug}.sh
mv  ${ROOT}/style.css ${ROOT}/user.css
sed -i 's/os.rename(tmpdir, target_dir)/shutil.move(tmpdir,target_dir)/' ${ROOT}/modules/ui_extensions.py
EOF

ENV CLI_ARGS=""
WORKDIR ${ROOT}
EXPOSE 7860
ENTRYPOINT /bin/bash $RUN_ARGS --ckpt-dir ${ROOT}/models/Stable-diffusion $CLI_ARGS
