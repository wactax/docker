#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ ! -d "kvrocks" ]; then
  latest_version=$(curl -s https://api.github.com/repos/apache/incubator-kvrocks/releases/latest | grep tag_name | cut -d '"' -f 4)
  git clone -b $latest_version --depth=1 git@github.com:apache/incubator-kvrocks.git kvrocks
fi

cd kvrocks
git checkout .
sed -i 's/ubuntu:focal/ubuntu:22/g' Dockerfile
docker build -t kvrocks .
