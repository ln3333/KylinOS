#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $openjdk8_image --no-cache -f kylin-V10SP2.openjdk8.Dockerfile
docker push $openjdk8_image

docker build . --build-arg BASE_IMAGE=$os_image -t $openjdk17_image --no-cache -f kylin-V10SP2.openjdk17.Dockerfile
docker push $openjdk17_image
