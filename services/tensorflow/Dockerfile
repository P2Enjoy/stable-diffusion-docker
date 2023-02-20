# syntax=docker/dockerfile:1
      
############################################################################################################################################################################################
FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04 as TENSORFLOW

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

#alias ARG=export ENV=export RUN=/bin/bash SHELL=echo COPY=echo
ENV LIBNVINFER_VERSION=7.2.2 
ENV LIBNVINFER_MAJOR_VERSION=7
ENV LIBNVINFER_CUDA_VERSION=11.1

ENV CUDNN_VERSION=8.1.1.33
ENV CUDNN_MAJOR_VERSION=8
ENV CUDNN_CUDA_VERSION=11.2

ENV CUDA_NVRTC="cuda-nvrtc-11-1"
ENV CUDA_NVRTC_DEV="cuda-nvrtc-dev-11-1"
ENV CUDA_NVRTC_VERSION=11.1.105-1

ENV COMPUTE=7.5
ENV MAX_GCC_VERSION=9

ENV GIT_BRANCH="v2.11.0"

ENV DEBIAN_FRONTEND=noninteractive 
ENV PIP_PREFER_BINARY=1 
ENV PIP_NO_CACHE_DIR=1
ENV TF_ENABLE_ONEDNN_OPTS=1
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

RUN <<EOF
#python
apt-get update
apt-get full-upgrade -y
apt-get install git curl -y
. /etc/os-release
echo "
deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main 
deb-src https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main 
" > /etc/apt/sources.list.d/python.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
apt-get update
apt-get install -y python3\.10-minimal libpython3\.10-dev libpython3\.10-stdlib
update-alternatives --install /usr/bin/python python $(which python3.10) 1
update-alternatives --install /usr/bin/python3 python3 $(which python3.10) 1
python --version
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
#bazel
apt install apt-transport-https curl gnupg -y
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
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
EOF

COPY ./scripts/requirements* /root/

WORKDIR /data
RUN <<EOF
#libs
apt-get install python3\.10-venv -y
python3 -m ensurepip
update-alternatives --install /usr/bin/pip pip $(which pip3.10) 1
update-alternatives --install /usr/bin/pip3 pip3 $(which pip3.10) 1

pip install --upgrade -r /root/requirements.txt
pip install -r /root/requirements_nodeps.txt --no-deps
apt-get install libcudnn${CUDNN_MAJOR_VERSION}=${CUDNN_VERSION}-1+cuda${CUDNN_CUDA_VERSION} libcudnn${CUDNN_MAJOR_VERSION}-dev=${CUDNN_VERSION}-1+cuda${CUDNN_CUDA_VERSION} libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-dev=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} libnvinfer-plugin-dev=${LIBNVINFER_VERSION}-1+cuda${LIBNVINFER_CUDA_VERSION} ${CUDA_NVRTC}=${CUDA_NVRTC_VERSION} ${CUDA_NVRTC_DEV}=${CUDA_NVRTC_VERSION} -y --allow-downgrades
EOF

COPY ./data /data/

RUN <<EOF
#nccl
if [[ ! -d /data/nccl ]]; then
	apt install -y devscripts debhelper fakeroot #build-essential
	git clone https://github.com/P2Enjoy/nccl.git
fi;
if [[ ! "$(ls -A /data/nccl/build/pkg/deb/*.deb)" ]];
then
	cd /data/nccl
	make -j src.build NVCC_GENCODE="-gencode=arch=compute_${COMPUTE/\./},code=sm_${COMPUTE/\./}"
	make pkg.debian.build
fi
dpkg -i /data/nccl/build/pkg/deb/*.deb
EOF

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda-11.2/targets/x86_64-linux/lib/:/usr/local/cuda-11.1/targets/x86_64-linux/lib/"
RUN <<EOF
#ldconfig
ldconfig -n /usr/local/cuda-*/targets/x86_64-linux/lib/ /usr/local/cuda/lib64/
EOF

RUN <<EOF
#sources
if [[ ! -d /data/tensorflow ]];
then
	git clone https://github.com/tensorflow/tensorflow
	cd /data/tensorflow
	git checkout ${GIT_BRANCH}
fi;
EOF

RUN <<EOF
#compile
apt update
apt install bazel bazel-$(cat /data/tensorflow/.bazelversion) -y
if [[ -s /data/tensorflow/.tf_configure.bazelrc ]] && [[ ! "$(ls -A /data/tensorflow-*.whl)" ]];
then
	cd /data/tensorflow
	#-Wno-sign-compare -march=native -DONEDNN_ARCH_OPT_FLAGS=-march=native -DONEDNN_GPU_RUNTIME=SYCL -DONEDNN_CPU_RUNTIME=SYCL -DONEDNN_ENABLE_CONCURRENT_EXEC=ON -DONEDNN_ENABLE_JIT_PROFILING=OFF -DONEDNN_ENABLE_ITT_TASKS=OFF -DONEDNN_EXPERIMENTAL=ON -DONEDNN_GPU_VENDOR=NVIDIA
	bazel build --local_ram_resources=8192 --config=linux --config=opt --config=mkl --config=cuda --config=tensorrt --config=xla //tensorflow/tools/pip_package:build_pip_package
fi
EOF

RUN <<EOF
#package
if [[ -s /data/tensorflow/.tf_configure.bazelrc ]] && [[ ! "$(ls -A /data/tensorflow-*.whl)" ]];
then
	cd /data/tensorflow
	bazel-bin/tensorflow/tools/pip_package/build_pip_package /data/
fi
EOF

COPY ./scripts/*.sh /root/

#################################################################################################################################################
RUN <<EOF
chmod +x /root/deploy.sh
EOF

WORKDIR /deploy
ENTRYPOINT ["/root/deploy.sh"]
CMD ["/bin/bash"]
