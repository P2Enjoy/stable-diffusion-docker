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
FROM alpine/git:2.36.2 as custom_scripts

ARG a1111_sd_webui_tagcomplete="353cb1937e82750d1859d6fd8c24e532c7d19e59"
ARG deforum_for_automatic1111_webui="ac8fed9ed705b43975dd14f69de3e253e69750dc"
ARG Txt2Vectorgraphics="2b780584f603b9abebba02527f3e0c3eed63426b"
ARG txt2mask="9abc4c68188d1bb5b6f69f4b38cc9947be1bd206"
ARG stable_diffusion_webui_cv2_external_masking_script="a6ae5ce5c1aabd51d4162850047a41914a38a593"
ARG Stable_diffusion_webui_video="87b78e07088287c2fa1a777e53c5bcfdcaf79aac"
ARG txt2imghd="96387631e48e64bbbaf1fcf2608a8be86bb7c730"
ARG embedding_to_png_script="a764f1b4e8c21d84ad36e72a9924078714d59b93"

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

WORKDIR /git

RUN git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git repositories/a1111-sd-webui-tagcomplete && cd repositories/a1111-sd-webui-tagcomplete && git reset --hard ${a1111_sd_webui_tagcomplete}
RUN git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git repositories/deforum-for-automatic1111-webui && cd repositories/deforum-for-automatic1111-webui && git reset --hard ${deforum_for_automatic1111_webui}
RUN git clone https://github.com/GeorgLegato/Txt2Vectorgraphics.git repositories/Txt2Vectorgraphics && cd repositories/Txt2Vectorgraphics && git reset --hard ${Txt2Vectorgraphics}
RUN git clone https://github.com/ThereforeGames/txt2mask.git repositories/txt2mask && cd repositories/txt2mask && git reset --hard ${txt2mask}
RUN git clone https://github.com/dfaker/stable-diffusion-webui-cv2-external-masking-script.git repositories/stable-diffusion-webui-cv2-external-masking-script && cd repositories/stable-diffusion-webui-cv2-external-masking-script && git reset --hard ${stable_diffusion_webui_cv2_external_masking_script}
RUN git clone https://github.com/memes-forever/Stable-diffusion-webui-video.git repositories/Stable-diffusion-webui-video && cd repositories/Stable-diffusion-webui-video && git reset --hard ${Stable_diffusion_webui_video}
RUN git clone https://github.com/jquesnelle/txt2imghd.git repositories/txt2imghd && cd repositories/txt2imghd && git reset --hard ${txt2imghd}
RUN git clone https://github.com/dfaker/embedding-to-png-script.git repositories/embedding-to-png-script && cd repositories/embedding-to-png-script && git reset --hard ${embedding_to_png_script}

############################################################################################################################################################################################
FROM python:3.10-slim

#tensorflow-cpu tensorflow-gpu intel-tensorflow intel-tensorflow-avx512
ARG TENSORFLOW="/data/tensorflow-*.whl"
ARG TENSORFLOW_VERSION="tensorflow=2.10"
ARG PIP_REPOSITORY="https://download.pytorch.org/whl/cu116"

ARG AUTO1111_SHA="c1093b8051606f0ac90506b7114c4b55d0447c70"		#https://github.com/AUTOMATIC1111/stable-diffusion-webui/commits/master
ARG GFPGAN_SHA="2eac2033893ca7f427f4035d80fe95b92649ac56"		#https://github.com/TencentARC/GFPGAN/commits/master
ARG CLIP_SHA="d50d76daa670286dd6cacf3bcd80b5e4823fc8e1"			#https://github.com/openai/CLIP/commits/main
ARG DeepDanbooru_SHA="12e3a13d1d0369f5008376907aa752188772dfe1"		#https://github.com/KichangKim/DeepDanbooru.git

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV EXTENSIONSDIR=${ROOT}/custom_scripts
ENV REPODIR=${ROOT}/repositories
ENV WORKDIR=${REPODIR}/stable-diffusion
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
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/KichangKim/DeepDanbooru.git@${DeepDanbooru_SHA}#egg=deepdanbooru[tensorflow] ${TENSORFLOW_VERSION} tensorflow-io==0.27.0
EOF

#################################################################################################################################################
COPY --from=custom_scripts /git/repositories/ ${EXTENSIONSDIR}

RUN <<EOF
# a1111-sd-webui-tagcomplete
cp -r ${EXTENSIONSDIR}/a1111-sd-webui-tagcomplete/{javascript,tags,scripts} ${ROOT}/
cp -r ${EXTENSIONSDIR}/a1111-sd-webui-tagcomplete/tags ${WORKDIR}/
EOF

RUN <<EOF
# deforum-for-automatic1111-webui
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
cp -r ${EXTENSIONSDIR}/deforum-for-automatic1111-webui/{deforum.py,deforum} ${ROOT}/scripts/
pip install --extra-index-url ${PIP_REPOSITORY} -r ${EXTENSIONSDIR}/deforum-for-automatic1111-webui/requirements.txt
EOF

RUN <<EOF
# Txt2Vectorgraphics
cp -r ${EXTENSIONSDIR}/Txt2Vectorgraphics/*.py ${ROOT}/scripts/
EOF

RUN <<EOF
# txt2mask
cp -r ${EXTENSIONSDIR}/txt2mask/{docs,repositories,scripts} ${ROOT}/
EOF

RUN <<EOF
# stable-diffusion-webui-cv2-external-masking-script
#cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-cv2-external-masking-script/external_masking.py ${ROOT}/scripts/
EOF

RUN <<EOF
# Stable-diffusion-webui-video
cp -r ${EXTENSIONSDIR}/Stable-diffusion-webui-video/videos.py ${ROOT}/scripts/
EOF

RUN <<EOF
# txt2imghd
cp -r ${EXTENSIONSDIR}/txt2imghd/txt2imghd.py ${ROOT}/scripts/
EOF

RUN <<EOF
# embedding-to-png-script
cp -r ${EXTENSIONSDIR}/embedding-to-png-script/embedding_to_png.py ${ROOT}/scripts/
EOF

RUN <<EOF
# apt
apt-get install curl tk potrace -y #libgtk2.0-dev
EOF

RUN <<EOF
# alternate_sampler_noise_schedules
curl -o ${ROOT}/scripts/alternate_sampler_noise_schedules.py https://gist.githubusercontent.com/dfaker/f88aa62e3a14b559fe4e5f6b345db664/raw/791dabfa0ab26399aa2635bcbc1cf6267aa4ffc2/alternate_sampler_noise_schedules.py
EOF

#################################################################################################################################################
RUN <<EOF
#gnupg
apt-get update
apt install gnupg2 -y
EOF

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

LIBNVINFER_MAJOR_VERSION=7
LIBNVINFER=7.2.2
CUDA_VERSION=11.1
apt install libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}-1+cuda${CUDA_VERSION} libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}-1+cuda${CUDA_VERSION} cuda-nvrtc-${CUDA_VERSION/./-} -y
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
