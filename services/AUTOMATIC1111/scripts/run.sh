#!/bin/bash

set -Eeuo pipefail

. /docker/mount.sh

source ${ROOT}/venv/bin/activate
# check python
python3 --version
# check libraries
pip freeze | tee /data/requirements.txt
#check tensors
python3 <<EOF
import tensorflow
from tensorflow.python.compiler.tensorrt import trt_convert as trt
print('tensorflow.__version__')
print(tensorflow.__version__)
print('trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version())
print('trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version())
EOF

python3 $@
