#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $oraclejdk8u202_image --no-cache -f kylin-V10SP2.oraclejdk8u202.Dockerfile
docker push $oraclejdk8u202_image
