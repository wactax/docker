#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

docker exec -it td sh -c "cd /backup && taosdump -u root -p$TD_PASSWORD -i /backup"
