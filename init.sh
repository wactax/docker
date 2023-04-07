#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

direnv allow

if ! [ -x "$(command -v direnv)" ]; then
  curl -sfL https://direnv.net/install.sh | bash
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  pip3 install docker-compose
fi

if [ -v 1 ]; then
  workdir=$1
else
  workdir=postgres.redis
fi

set -ex

if [ ! -d "wac/data" ]; then
  NO_DATA=1
fi

if [ ! -f "wac/env" ]; then
  direnv exec . ./env.coffee
fi

if [ ! -f "wac/docker-compose.yml" ]; then
  cp $workdir/docker-compose.yml wac
fi

cp -rf sh/wac/. wac

cd wac
./down.sh
if [ -n "$NO_DATA" ]; then
  rm -rf data
  if [ "$(uname)" == "Linux" ]; then
    mkdir -p /mnt/data/wac
    ln -s /mnt/data/wac data
    mkdir -p /var/log/wac
    ln -s /var/log/wac log
    mkdir -p /mnt/backup/docker
    ln -s /mnt/backup/docker backup
  fi
fi
./up.without_api.sh
direnv allow
cd ..

if [ -f $workdir/init.sh ]; then
  direnv exec . ./$workdir/init.sh
fi

set_env() {
  set -o allexport
  source ./wac/env
  set +o allexport
}

set_env

export REDIS_HOST=127.0.0.1
export REDIS_HOST_PORT=$REDIS_HOST:$REDIS_PORT
export PG_HOST=127.0.0.1
export PG_URI=$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$PG_DB

sleep 12
../../api/init.sh
../../api/dist.sh
./api/build.sh
set_env
cd wac
docker-compose stop api
yes | docker-compose rm api
docker-compose up -d api
git init && git add . && git commit -minit || true
