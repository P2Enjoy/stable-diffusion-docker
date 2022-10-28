# syntax=docker/dockerfile:1

############################################################################################################################################################################################
FROM alpine/git:2.36.2 as download

ARG stableDiffusion_SHA="a7e3c9820e064da54bdc97abe143caaf1a06b751"	#https://github.com/P2Enjoy/stable-diffusion.git
ARG codeFormer_SHA="fa547b7aba3ef0a2b1b8db9956e6dba2984de218"		#https://github.com/P2Enjoy/CodeFormer.git
ARG BLIP_SHA="3a29b7410476bf5f2ba0955827390eb6ea1f4f9d"			#https://github.com/P2Enjoy/BLIP.git
ARG latentDiffusion_SHA="abf33e7002d59d9085081bce93ec798dcabd49af"	#https://github.com/P2Enjoy/latent-diffusion.git
ARG tamingTransformers_SHA="24268930bf1dce879235a7fddd0b2355b84d7ea6"	#https://github.com/P2Enjoy/taming-transformers.git
ARG kDiffusion_SHA="f4e99857772fc3a126ba886aadf795a332774878"		#https://github.com/P2Enjoy/k-diffusion.git
ARG clip_interrogator_SHA="2486589f24165c8e3b303f84e9dbbea318df83e8"	#https://github.com/P2Enjoy/clip-interrogator.git

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

WORKDIR /git
RUN git clone https://github.com/P2Enjoy/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard ${stableDiffusion_SHA}
RUN git clone https://github.com/P2Enjoy/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard ${codeFormer_SHA}
RUN git clone https://github.com/P2Enjoy/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard ${BLIP_SHA}
RUN git clone https://github.com/P2Enjoy/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard ${latentDiffusion_SHA}
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
FROM alpine/git:2.36.2 as custom_scripts

# CUSTOM SCRIPTS
ARG a1111_sd_webui_tagcomplete="dc77b3f17f8a796e19b54331263fa51fd29a9c25"				#https://github.com/P2Enjoy/a1111-sd-webui-tagcomplete.git
ARG Txt2Vectorgraphics="2b780584f603b9abebba02527f3e0c3eed63426b"					#https://github.com/P2Enjoy/Txt2Vectorgraphics.git
ARG txt2mask="9abc4c68188d1bb5b6f69f4b38cc9947be1bd206"							#https://github.com/P2Enjoy/txt2mask.git
ARG stable_diffusion_webui_cv2_external_masking_script="558f6b0b93168a9a16771c8d5d9dde7961f6b5e2"	#https://github.com/P2Enjoy/stable-diffusion-webui-cv2-external-masking-script.git
ARG Stable_diffusion_webui_video="87b78e07088287c2fa1a777e53c5bcfdcaf79aac"				#https://github.com/P2Enjoy/Stable-diffusion-webui-video.git
ARG txt2imghd="96387631e48e64bbbaf1fcf2608a8be86bb7c730"						#https://github.com/P2Enjoy/txt2imghd.git
ARG embedding_to_png_script="0fe7ed0c88939afaca066ccb0fea04d441bb9669"					#https://github.com/P2Enjoy/embedding-to-png-script.git
# EXTENSIONS
ARG deforum_for_automatic1111_webui="2eed36919087ff025765c7aed271b6dd930e6e61"				#https://github.com/P2Enjoy/deforum-for-automatic1111-webui.git
ARG stable_diffusion_webui_aesthetic_gradients="411889ca602f20b8bb5e4d1af2b9686eab1913b1" 		#https://github.com/P2Enjoy/stable-diffusion-webui-aesthetic-gradients.git
ARG stable_diffusion_webui_images_browse="51fd743564c75cdae2bd57b8601ba8ed98d541c4" 			#https://github.com/P2Enjoy/stable-diffusion-webui-images-browser.git
ARG stable_diffusion_webui_inspiration="82c645007205ce6675bdcf4274f0cc2a4eeed71a"			#https://github.com/P2Enjoy/stable-diffusion-webui-inspiration.git
ARG stable_diffusion_webui_artists_to_study="665c7f4ff519cce6c9132c896b685fa33065ba7f"			#https://github.com/P2Enjoy/stable-diffusion-webui-artists-to-study.git
ARG stable_diffusion_webui_aesthetic_image_scorer="5ccd3004f9a9efb5b8ca2bce91fe4fbb0c8070be"	 	#https://github.com/P2Enjoy/stable-diffusion-webui-aesthetic-image-scorer.git

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

WORKDIR /git

# CUSTOM SCRIPTS
RUN git clone https://github.com/P2Enjoy/a1111-sd-webui-tagcomplete.git repositories/a1111-sd-webui-tagcomplete && cd repositories/a1111-sd-webui-tagcomplete && git reset --hard ${a1111_sd_webui_tagcomplete}
RUN git clone https://github.com/P2Enjoy/Txt2Vectorgraphics.git repositories/Txt2Vectorgraphics && cd repositories/Txt2Vectorgraphics && git reset --hard ${Txt2Vectorgraphics}
RUN git clone https://github.com/P2Enjoy/txt2mask.git repositories/txt2mask && cd repositories/txt2mask && git reset --hard ${txt2mask}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-webui-cv2-external-masking-script.git repositories/stable-diffusion-webui-cv2-external-masking-script && cd repositories/stable-diffusion-webui-cv2-external-masking-script && git reset --hard ${stable_diffusion_webui_cv2_external_masking_script}
RUN git clone https://github.com/P2Enjoy/Stable-diffusion-webui-video.git repositories/Stable-diffusion-webui-video && cd repositories/Stable-diffusion-webui-video && git reset --hard ${Stable_diffusion_webui_video}
RUN git clone https://github.com/P2Enjoy/txt2imghd.git repositories/txt2imghd && cd repositories/txt2imghd && git reset --hard ${txt2imghd}
RUN git clone https://github.com/P2Enjoy/embedding-to-png-script.git repositories/embedding-to-png-script && cd repositories/embedding-to-png-script && git reset --hard ${embedding_to_png_script}
# EXTENSIONS
RUN git clone https://github.com/P2Enjoy/deforum-for-automatic1111-webui.git repositories/deforum-for-automatic1111-webui && cd repositories/deforum-for-automatic1111-webui && git reset --hard ${deforum_for_automatic1111_webui}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-webui-aesthetic-gradients.git repositories/stable-diffusion-webui-aesthetic-gradients && cd repositories/stable-diffusion-webui-aesthetic-gradients && git reset --hard ${stable_diffusion_webui_aesthetic_gradients}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-webui-images-browser.git repositories/stable-diffusion-webui-images-browser && cd repositories/stable-diffusion-webui-images-browser && git reset --hard ${stable_diffusion_webui_images_browse}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-webui-inspiration.git repositories/stable-diffusion-webui-inspiration && cd repositories/stable-diffusion-webui-inspiration && git reset --hard ${stable_diffusion_webui_inspiration}
RUN git clone https://github.com/P2Enjoy/stable-diffusion-webui-artists-to-study.git repositories/stable-diffusion-webui-artists-to-study && cd repositories/stable-diffusion-webui-artists-to-study && git reset --hard ${stable_diffusion_webui_artists_to_study}
RUN git clone --recurse-submodules https://github.com/P2Enjoy/stable-diffusion-webui-aesthetic-image-scorer.git repositories/stable-diffusion-webui-aesthetic-image-scorer && cd repositories/stable-diffusion-webui-aesthetic-image-scorer && git reset --hard ${stable_diffusion_webui_aesthetic_image_scorer}

RUN <<EOF
#dos2unix
apk add --no-cache dos2unix
dos2unix /git/repositories/**/*
EOF

############################################################################################################################################################################################
FROM python:3.10-slim

#tensorflow-cpu tensorflow-gpu intel-tensorflow intel-tensorflow-avx512
ARG TENSORFLOW_VERSION="tensorflow==2.10"
ARG PIP_REPOSITORY="https://download.pytorch.org/whl/cu116"

#last good
#c57919ea2a8e4a23a05d21f28928e08bbf34c59e 
#latest
#3e15f8e0f5cc87507f77546d92435670644dbd18
ARG AUTO1111_SHA="737eb28faca8be2bb996ee0930ec77d1f7ebd939"		#https://github.com/P2Enjoy/stable-diffusion-webui.git
ARG GFPGAN_SHA="2eac2033893ca7f427f4035d80fe95b92649ac56"		#https://github.com/P2Enjoy/GFPGAN.git
ARG CLIP_SHA="d50d76daa670286dd6cacf3bcd80b5e4823fc8e1"			#https://github.com/P2Enjoy/CLIP.git
ARG DeepDanbooru_SHA="c48689a85dde0e4a852c1691a7d746abe242e283"		#https://github.com/P2Enjoy/DeepDanbooru.git

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/stable-diffusion-webui
ENV EXTENSIONSDIR=${ROOT}/custom_scripts
ENV REPODIR=${ROOT}/repositories
ENV WORKDIR=${REPODIR}/stable-diffusion
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV USE_MEMORY_EFFICIENT_ATTENTION=1
ENV MAX_GCC_VERSION=10
ENV RUN_ARGS='ECHO Please specify the command line runner from the composer'

RUN apt-get update && apt-get install fonts-dejavu-core rsync git jq moreutils dos2unix -y && apt-get full-upgrade -y && apt-get autopurge -y

#GCC
RUN <<EOF
apt-get install gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
EOF

RUN <<EOF
git clone https://github.com/P2Enjoy/stable-diffusion-webui.git ${ROOT}
cd ${ROOT}
git pull --rebase
git reset --hard ${AUTO1111_SHA}
dos2unix ${ROOT}/**/*
python -m venv venv
source ${ROOT}/venv/bin/activate
python -m ensurepip
EOF

COPY --from=download /git/ ${ROOT}

RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/data/* ${ROOT}/interrogate

RUN <<EOF
# Build requirements
source ${ROOT}/venv/bin/activate
pip install --upgrade pip

pip install --extra-index-url ${PIP_REPOSITORY} setuptools
pip install --extra-index-url ${PIP_REPOSITORY} wheel
pip install --extra-index-url ${PIP_REPOSITORY} ninja
pip install --extra-index-url ${PIP_REPOSITORY} pyngrok
EOF

COPY ./data/*.whl /docker/
RUN <<EOF
# tensorflow, torch
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} /docker/tensorflow-*.whl /docker/torch-*.whl
pip install --extra-index-url ${PIP_REPOSITORY} torchvision==0.13.1+cu116
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
pip install gradio==3.4.1
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
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/P2Enjoy/GFPGAN.git@${GFPGAN_SHA}
EOF

RUN <<EOF
# CLIP
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/P2Enjoy/CLIP.git@${CLIP_SHA}
EOF

COPY ./data/xformers-*.whl /docker/
RUN <<EOF
# xformers
cd ${ROOT}
source ${ROOT}/venv/bin/activate
pip install --extra-index-url ${PIP_REPOSITORY} /docker/xformers-*.whl
EOF

RUN <<EOF
# DeepDanbooru
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} git+https://github.com/P2Enjoy/DeepDanbooru.git@${DeepDanbooru_SHA}#egg=deepdanbooru[tensorflow] ${TENSORFLOW_VERSION} tensorflow-io==0.27.0
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

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda-11.2/targets/x86_64-linux/lib/:/usr/local/cuda-11.1/targets/x86_64-linux/lib/:/usr/local/cuda-11.0/targets/x86_64-linux/lib"
RUN <<EOF
#fix LDCONFIG
ldconfig
EOF

###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT###CUSTOM-SCRIPT##
COPY --from=custom_scripts /git/repositories/ ${EXTENSIONSDIR}

RUN <<EOF
# apt for extensions/custom scripts
apt-get install tk potrace ffmpeg unzip -y #libgtk2.0-dev
EOF

RUN <<EOF
# a1111-sd-webui-tagcomplete
cp -r ${EXTENSIONSDIR}/a1111-sd-webui-tagcomplete/{javascript,tags,scripts} ${ROOT}/
cp -r ${EXTENSIONSDIR}/a1111-sd-webui-tagcomplete/tags ${WORKDIR}/
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
# alternate_sampler_noise_schedules
curl -o ${ROOT}/scripts/alternate_sampler_noise_schedules.py https://gist.githubusercontent.com/dfaker/f88aa62e3a14b559fe4e5f6b345db664/raw/791dabfa0ab26399aa2635bcbc1cf6267aa4ffc2/alternate_sampler_noise_schedules.py
dos2unix ${ROOT}/scripts/alternate_sampler_noise_schedules.py
EOF

###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS###EXTENSIONS
RUN <<EOF
# aesthetic_gradients
mkdir -p ${ROOT}/extensions
cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-aesthetic-gradients ${ROOT}/extensions/aesthetic-gradients
EOF

RUN <<EOF
# image_browser
mkdir -p ${ROOT}/extensions
cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-images-browser ${ROOT}/extensions/stable-diffusion-webui-images-browser
EOF

RUN <<EOF
# webui-inspiration
mkdir -p ${ROOT}/extensions
cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-inspiration ${ROOT}/extensions/stable-diffusion-webui-inspiration
EOF

RUN <<EOF
# webui-artists-to-study
mkdir -p ${ROOT}/extensions
cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-artists-to-study ${ROOT}/extensions/stable-diffusion-webui-artists-to-study
EOF

RUN <<EOF
# aesthetic-image-score
mkdir -p ${ROOT}/extensions
cp -r ${EXTENSIONSDIR}/stable-diffusion-webui-aesthetic-image-scorer ${ROOT}/extensions/stable-diffusion-webui-aesthetic-image-scorer
EOF

RUN <<EOF
# deforum-for-automatic1111-webui
mkdir -p ${ROOT}/extensions
source ${ROOT}/venv/bin/activate
pip install --upgrade pip
pip install --extra-index-url ${PIP_REPOSITORY} -r ${EXTENSIONSDIR}/deforum-for-automatic1111-webui/requirements.txt
cp -r ${EXTENSIONSDIR}/deforum-for-automatic1111-webui ${ROOT}/extensions/deforum
EOF

#################################################################################################################################################
COPY ./scripts /docker/

RUN <<EOF
source ${ROOT}/venv/bin/activate
chmod +x /docker/{run,mount,debug}.sh && python3 /docker/info.py ${ROOT}/modules/ui.py
EOF

ENV CLI_ARGS=""
WORKDIR ${ROOT}
EXPOSE 7860
# run, -u to not buffer stdout/stderr
ENTRYPOINT /bin/bash $RUN_ARGS --ckpt-dir ${ROOT}/models/Stable-diffusion $CLI_ARGS
