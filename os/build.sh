#!/bin/bash -ex

source ../common.sh

docker build . --no-cache -f kylin-V10SP2.os.Dockerfile -t $os_image
docker push $os_image