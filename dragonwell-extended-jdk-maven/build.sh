#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$dragonwell_extended8_image -t $dragonwell_extended8_maven3_9_image --no-cache -f kylin-V10SP2.dragonwell-extended8-maven.Dockerfile
docker push $dragonwell_extended8_maven3_9_image

docker build . --build-arg BASE_IMAGE=$dragonwell_extended21_image -t $dragonwell_extended21_maven3_9_image --no-cache -f kylin-V10SP2.dragonwell-extended21-maven.Dockerfile
docker push $dragonwell_extended21_maven3_9_image

