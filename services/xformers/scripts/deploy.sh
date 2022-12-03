#!/bin/bash

set -Eeuo pipefail

if [[ "$(ls -A /deploy/xformers-*.whl)" ]];
then
	echo "Testing the build"
	source /xformers/venv/bin/activate
	# check python 
	python3 --version
	# check wheel install
	pip install --upgrade --force-reinstall /deploy/tensorflow-*.whl
	# check and export libraries
	pip freeze > /deploy/xformers-requirements.txt
	# benchmark
	python -m xformers.info
	#python3 /xformers/xformers/benchmarks/benchmark_encoder.py --activations relu  --plot -emb 256 -bs 32 -heads 16
else
	echo "xformers WHEEL being cached in ./data folder"
	cp /xformers/dist/*.whl /deploy/
	echo "Run container again to benchmark"
fi;
