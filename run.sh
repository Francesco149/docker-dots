#!/bin/sh

if [ -f /.dockerenv ]; then
  echo "running inside docker, this was probably unintended"
  exit 1
fi

dir="$(dirname "$0")"
abspath="$(realpath "$dir")"
olddir="$(pwd)"
cd $abspath

while [[ true ]]; do
  ./once.sh
  sleep 1
done

cd $olddir
