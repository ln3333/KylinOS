#!/bin/bash

source common.sh

# 构建镜像
docker build . --build-arg BASE_IMAGE=$os_image -t $all_tools_image --no-cache -f kylin-V10SP2.all-tools.Dockerfile

# 推送镜像
docker push $all_tools_image

