#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. .env.set
docker-compose stop api
docker-compose config --services | grep -v "^api$" | xargs docker-compose up -d
