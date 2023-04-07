#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

. .env.set
../api/build.sh
docker-compose restart api
# docker-compose stop api
# yes | docker-compose rm api
# docker-compose up -d api
