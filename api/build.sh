#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

docker run --rm \
  -v $DIR/src:/src -it \
  node:19-alpine \
  sh -c "npm config set registry http://mirrors.cloud.tencent.com/npm/ && npm i -g pnpm && cd src && pnpm i --production && pnpm prune --production"
