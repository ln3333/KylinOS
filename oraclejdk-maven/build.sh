#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$oraclejdk8u202_image -t $oraclejdk8u202_maven3_9_image --no-cache -f kylin-V10SP2.oraclejdk8u202-maven.Dockerfile
docker push $oraclejdk8u202_maven3_9_image
