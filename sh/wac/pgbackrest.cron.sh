#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}

./cron_add "0 * *" $DIR pgbackrest.sh wac-pg site incr
./cron_add "30 3 */5" $DIR pgbackrest.sh wac-pg site full
