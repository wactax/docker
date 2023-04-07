#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

cd ..
./Dockerfile/redis/acl.coffee

conf=wac/conf/pgbackrest
if [ ! -f "$conf/pgbackrest.conf" ]; then
  mkdir -p $conf
  cp ./Dockerfile/postgres/pgbackrest.conf $conf
fi
