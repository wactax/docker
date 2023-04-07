#!/usr/bin/env bash

set -ex
docker exec wac-pg pgbackrest info
