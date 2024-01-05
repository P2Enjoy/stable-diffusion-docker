#!/bin/bash

set -Eeuo pipefail

# activating the virtual environment
source /venv/bin/activate;

export NO_TCMALLOC="True"
#export XDG_CACHE_HOME=/root/.cache
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Finalising the docker environment
. /docker/mount.sh

# check python
python3 --version
# check libraries
pip freeze | tee /data/requirements.txt


export LD_PRELOAD=libtcmalloc.so
if [[ ! -z "${ACCELERATE}" ]] && [[ "${ACCELERATE}" = "True" ]] && [[ -x "$(command -v accelerate)" ]]
then
    echo "Accelerating SD with distributed GPU+CPU..."
    accelerate launch --num_cpu_threads_per_process=6 $@
else
    python3 -u $@
fi

echo "Shutting down in 10 seconds"
sleep 10
