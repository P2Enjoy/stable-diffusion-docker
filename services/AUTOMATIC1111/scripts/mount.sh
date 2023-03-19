#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS INTERNAL_MOUNTS

mkdir -p /data/config/auto/scripts/
if [ ! -s /data/config/auto/config.json ]; then
  cp /docker/config.json /data/config/auto/config.json
fi
if [ ! -s /data/config/auto/ui-config.json ]; then
  cp /docker/ui-config.json /data/config/auto/ui-config.json
fi
# copy, we cannot just mount the directory because it will override the already provided scripts in the repo
cp -rfT /data/config/auto/scripts/ "${ROOT}/scripts"
#cp -rfT /data/dataset/textual_inversion_templates/ "${ROOT}/textual_inversion_templates"

MOUNTS["/root/.cache"]="/data/.cache"

# main
MOUNTS["${ROOT}/models/Stable-diffusion"]="/data/StableDiffusion"
MOUNTS["${ROOT}/models/VAE"]="/data/VAE"
MOUNTS["${ROOT}/models/Codeformer"]="/data/Codeformer"
MOUNTS["${ROOT}/models/GFPGAN"]="/data/GFPGAN"
MOUNTS["${ROOT}/models/ESRGAN"]="/data/ESRGAN"
MOUNTS["${ROOT}/models/BSRGAN"]="/data/BSRGAN"
MOUNTS["${ROOT}/models/RealESRGAN"]="/data/RealESRGAN"
MOUNTS["${ROOT}/models/SwinIR"]="/data/SwinIR"
MOUNTS["${ROOT}/models/ScuNET"]="/data/ScuNET"
MOUNTS["${ROOT}/models/LDSR"]="/data/LDSR"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/Hypernetworks"
MOUNTS["${ROOT}/models/deepbooru"]="/data/deepbooru"
MOUNTS["${ROOT}/models/mmdet"]="/data/mmdet"
MOUNTS["${ROOT}/models/Deforum"]="/data/Deforum"
MOUNTS["${ROOT}/models/Interrogator"]="/data/Interrogator"
MOUNTS["${ROOT}/models/BLIP"]="/data/Interrogator"
MOUNTS["${ROOT}/models/torch_deepdanbooru"]="/data/torch_deepdanbooru"
MOUNTS["${ROOT}/models/midas"]="/data/midas"
MOUNTS["${ROOT}/models/pix2pix"]="/data/pix2pix"
MOUNTS["${ROOT}/models/leres"]="/data/leres"
MOUNTS["${ROOT}/models/LoRA"]="/data/LoRA"
MOUNTS["${ROOT}/models/lora"]="/data/LoRA"
MOUNTS["${ROOT}/models/Lora"]="/data/LoRA"
MOUNTS["${ROOT}/models/dreambooth"]="/data/dreambooth"
MOUNTS["${ROOT}/models/VAE-approx"]="/data/VAE-approx"
MOUNTS["${ROOT}/models/3dphoto"]="/data/3dphoto"
MOUNTS["${ROOT}/models/Autoprune"]="/data/Autoprune"
MOUNTS["${ROOT}/models/Components"]="/data/Components"
MOUNTS["${ROOT}/models/rem_bg"]="/data/rem_bg"
MOUNTS["${ROOT}/models/ControlNet"]="/data/ControlNet"


# hacks
#MOUNTS["${ROOT}/extensions"]="/data/config/auto/extensions"

MOUNTS["${ROOT}/embeddings"]="/data/embeddings"

MOUNTS["${ROOT}/textual_inversion_templates"]="/data/dataset/textual_inversion_templates"
MOUNTS["${ROOT}/textual_inversion"]="/data/dataset/textual_inversion"
MOUNTS["${ROOT}/dream_artist"]="/data/dataset/textual_inversion"

# extra hacks
MOUNTS["${ROOT}/repositories/CodeFormer/weights/facelib"]="/data/.cache"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

INTERNAL_MOUNTS["${ROOT}/config.json"]="/data/config/auto/config.json"
INTERNAL_MOUNTS["${ROOT}/ui-config.json"]="/data/config/auto/ui-config.json"

for to_path in "${!INTERNAL_MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${INTERNAL_MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted internal link "${from_path}"
done

#jq '. * input' /data/config/auto/config.json | sponge /data/config/auto/config.json
mkdir -p /output/saved /output/txt2img-images/ /output/img2img-images /output/extras-images/ /output/grids/ /output/txt2img-grids/ /output/img2img-grids/

if [ -f "/data/config/auto/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/auto/startup.sh
  popd
fi

