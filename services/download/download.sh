#!/usr/bin/env bash

set -Eeuo pipefail

mkdir -vp /data/.cache /data/StableDiffusion /data/Codeformer /data/GFPGAN /data/ESRGAN /data/BSRGAN /data/RealESRGAN /data/SwinIR /data/LDSR /data/ScuNET /data/embeddings /data/VAE /data/deepbooru /data/mmdet

cat <<EOF
By using this software, you agree to the following licenses:
https://github.com/CompVis/stable-diffusion/blob/main/LICENSE
https://github.com/TencentARC/GFPGAN/blob/master/LICENSE
https://github.com/xinntao/Real-ESRGAN/blob/master/LICENSE
EOF

echo "Downloading, this might take a while..."

aria2c --input-file /docker/links.txt --dir /data --continue --disable-ipv6
[[ -s /docker/links_extended.txt ]] && aria2c --input-file /docker/links_extended.txt --dir /data --continue --disable-ipv6

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"

# fix potential permissions
# TODO: need something better than this:
# chmod -R 777 /data /output
