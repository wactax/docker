#!/usr/bin/env bash

set -ex

pgrep pgbackrest && echo "another pgbackrest runing" && exit || true
docker_name=$1
stanza=$2
backup_type=$3

backup() {
  docker exec -u postgres $docker_name pgbackrest --stanza=$stanza \
    --type $backup_type backup $@
}

backup
backup --repo=2
