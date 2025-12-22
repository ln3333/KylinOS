#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$openjdk8_image -t $openjdk8_maven3_9_image --no-cache -f kylin-V10SP2.openjdk8-maven.Dockerfile
docker push $openjdk8_maven3_9_image

docker build . --build-arg BASE_IMAGE=$openjdk17_image -t $openjdk17_maven3_9_image --no-cache -f kylin-V10SP2.openjdk17-maven.Dockerfile
docker push $openjdk17_maven3_9_image
