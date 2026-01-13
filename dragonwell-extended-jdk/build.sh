#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $dragonwell_extended8_image --no-cache -f kylin-V10SP2.dragonwell-extended8.Dockerfile
docker push $dragonwell_extended8_image

docker build . --build-arg BASE_IMAGE=$os_image -t $dragonwell_extended21_image --no-cache -f kylin-V10SP2.dragonwell-extended21.Dockerfile
docker push $dragonwell_extended21_image

