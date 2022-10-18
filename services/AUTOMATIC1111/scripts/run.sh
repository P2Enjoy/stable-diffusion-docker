#!/bin/bash

set -Eeuo pipefail

. /docker/mount.sh
source ../../venv/bin/activate
python3 --version
pip freeze /data/requirements.txt
python3 $@
