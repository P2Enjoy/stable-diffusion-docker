#!/bin/bash
#install-container-dep

if [ ! -d "/venv" ];
then
  pip install --upgrade virtualenv
  virtualenv -p python3 /venv
fi
source /venv/activate;
pip install --extra-index-url ${PIP_REPOSITORY} $@
