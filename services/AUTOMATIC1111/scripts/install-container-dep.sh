#!/bin/bash
#install-container-dep

if [ ! -f "/docker/webui-requirements.txt" ]; 
then
  pip install --extra-index-url ${PIP_REPOSITORY} $@
fi;
