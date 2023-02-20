#!/bin/bash

set -Eeuo pipefail

# Deploy DEB libraries
if [[ ! "$(ls -A /deploy/libs/*.deb)" ]];
then
	echo "DEBIAN PACKAGES REQUIRED FOR COMPILING THE SOURCES OF tensorflow ARE BEING CACHED ON ./data folder"
	PACKAGES="libcudnn${CUDNN_MAJOR_VERSION}=${CUDNN_VERSION}-1+cuda${CUDNN_CUDA_VERSION} libcudnn${CUDNN_MAJOR_VERSION}-dev=${CUDNN_VERSION}-1+cuda${CUDNN_CUDA_VERSION} libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-dev=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-plugin-dev=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} ${CUDA_NVRTC}=${CUDA_NVRTC_VERSION} ${CUDA_NVRTC_DEV}=${CUDA_NVRTC_VERSION}";
	#apt-get install aptitude -y
	#aptitude clean
	#aptitude --download-only install --reinstall $PACKAGES
	#cp /var/cache/apt/**/*.deb /deploy/
	mkdir -p /deploy/libs
	cd /deploy/libs
	#apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends ${PACKAGES} | grep "^\w") 
	apt-get download ${PACKAGES} 
fi;

# Deploy nccl
if [[ -d /data/nccl/build/pkg/deb ]] && [[ ! "$(ls -A /deploy/nccl/build/pkg/deb/*.deb)" ]];
then
	echo "COMPILED SOURCES OF nccl ARE BEING CACHED ON ./data folder"
	mkdir -p /deploy/nccl/build/pkg/deb
	cp /data/nccl/build/pkg/deb/*.deb /deploy/nccl/build/pkg/deb/
	echo "DONE: docker compose --profile tensorflow up --build WILL USE THE PRECOMPILED VERSIONS OF nccl FROM NOW ON"
fi

# Deploy tensorflow
if [[ -d /data/tensorflow ]] && [[ ! -d /deploy/tensorflow ]];
then
	echo "CLONED SOURCES OF tensorflow ARE BEING CACHED ON ./data folder"
	mkdir -p /deploy/tensorflow
	cp -R /data/tensorflow /deploy/
	echo "docker compose --profile tensorflow up --build WILL USE THE PRECLONED VERSIONS OF tensorflow FROM NOW ON"
fi

# Install the built tensorflow
cd $HOME

if [[ "$(ls -A /data/tensorflow-*.whl)" ]];
then
	if [[ ! "$(ls -A /deploy/tensorflow-*.whl)" ]];
	then
		echo "COMPILED WHEELS OF tensorflow ARE BEING CACHED ON ./data folder"
		cp /data/tensorflow-*.whl /deploy/
	fi
	
	# check python 
	python3 --version
	# check wheel install
	pip install --upgrade --force-reinstall /deploy/tensorflow-*.whl
	# check and export libraries
	pip freeze > /deploy/tensorflow-requirements.txt
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
else
	echo "Tensorflow have NOT been compiled YET because they require configuration"
	echo "
Log into the running container to configure the tensorflow: 
	\$ docker-compose exec webui-tensorflow-docker-1 bash
	\$ cd /deploy/tensorflow
	\$ ./configure"
	while [[ -z $(grep '[^[:space:]]' /deploy/tensorflow/.tf_configure.bazelrc) ]];
	do
	        sleep 5;
	done
	echo "CONFIGURED! PLEASE RUN THE CONTAINER AGAIN TO COMPILE"
fi;

$@
