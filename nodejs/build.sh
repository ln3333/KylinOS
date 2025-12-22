#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $nvm_image --no-cache -f kylin-V10SP2.nvm.Dockerfile
docker push $nvm_image

