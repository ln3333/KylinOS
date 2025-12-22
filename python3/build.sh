#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $pyenv_image --no-cache -f kylin-V10SP2.pyenv.Dockerfile
docker push $pyenv_image

docker build . --build-arg BASE_IMAGE=$pyenv_image -t $pyenv_oracle_image --no-cache -f kylin-V10SP2.pyenv-oracle.Dockerfile
docker push $pyenv_oracle_image
