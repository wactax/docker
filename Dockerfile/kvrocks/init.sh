#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ -d "kvrocks" ]; then
  cd kvrocks
  git pull
else
  #latest_version=$(curl -s https://api.github.com/repos/apache/incubator-kvrocks/releases/latest | grep tag_name | cut -d '"' -f 4)
  latest_version=unstable
  git clone -b $latest_version --depth=1 git@github.com:apache/incubator-kvrocks.git kvrocks
  cd kvrocks
fi

git checkout .
sed -i 's/ubuntu:focal/ubuntu:jammy/g' Dockerfile || true
docker build -t kvrocks .
