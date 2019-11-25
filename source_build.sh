#!/bin/bash
SUBDIR="green_public blue_public"
Build_volume_name="www_src"
BuildVersion="0.3"
for i in $SUBDIR
do
	docker build -f Dockerfile_src --build-arg PRODUCT=$PRODUCT --build-arg VER=${BuildVersion} --build-arg SUBDIR=${i} --no-cache -t  "www_"${i}:${BuildVersion} .
done
#docker build -f Dockerfile_src --build-arg PRODUCT=$PRODUCT --build-arg VER=${BuildVersion} --build-arg SUBDIR=${SUBDIR} --no-cache -t  ${Build_volume_name}:${BuildVersion} .
