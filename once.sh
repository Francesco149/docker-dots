#!/bin/sh

if [ -f /.dockerenv ]; then
  echo "running inside docker, this was probably unintended"
  exit 1
fi

dir="$(dirname "$0")"
abspath="$(realpath "$dir")"
olddir="$(pwd)"
cd $abspath
name="memevault"
docker build -t $name . && \
docker run --rm \
  --link adbd:adbd \
  --volume "/$name":/home/loli \
  --volume ~/.ssh:/home/loli/.ssh \
  --volume "/$name/toolchains/fsl-imx-fb":/opt/fsl-imx-fb \
  --device /dev/ttyACM1 \
  --name $name \
  --hostname $name \
  --publish 22:22 \
  $name

cd $olddir
