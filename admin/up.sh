#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

mkdir -p ./data/redisinsight
chown -R 1001 ./data/redisinsight
docker-compose up -d

