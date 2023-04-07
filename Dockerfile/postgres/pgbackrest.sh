#!/usr/bin/env bash

set -ex

stanza=site
pgconf="$PGDATA/postgresql.conf"
hbaconf="$PGDATA/pg_hba.conf"
pgbackrestconf="/etc/pgbackrest/pgbackrest.conf"

# init pgbackrest
if ! grep -q "pgbackrest" "$pgconf"; then
  echo "host all all all trust" >>$hbaconf
  echo "unix_socket_directories = '/var/run/postgresql'" >>$pgconf
  echo "port = $PGPORT" >>$pgconf
  sed -i '/^max_wal_size\s*=/d' $pgconf
  sed -i '/^min_wal_size\s*=/d' $pgconf
  echo "archive_command = 'pgbackrest --stanza=site archive-push %p'" >>$pgconf
  echo "archive_mode = on" >>$pgconf
  echo "log_directory = '/log'" >>$pgconf
  echo "log_filename = '%Y-%m-%d_%H%M%S.log'" >>$pgconf
  echo "log_line_prefix = ''" >>$pgconf
  echo "log_rotation_age = 7d" >>$pgconf
  echo "logging_collector = on" >>$pgconf
  echo "max_wal_senders = 3" >>$pgconf
  echo "max_wal_size = 8GB" >>$pgconf
  echo "min_wal_size = 80MB" >>$pgconf
  echo "wal_level = hot_standby" >>$pgconf
  echo "hot_standby = on" >>$pgconf

  pg_ctl start -o "-p $PGPORT -k /var/run/postgresql" -D $PGDATA

  sed -i "s/^pg1-user.*/pg1-user=$POSTGRES_USER/" $pgbackrestconf
  # sed -i "s/^pg1-pass.*/pg1-pass = $POSTGRES_PASSWORD/" $pgbackrestconf

  pgbackrest --stanza=$stanza --pg1-port=$PGPORT \
    --log-level-console=info stanza-create
  pg_ctl restart -o "-p $PGPORT -k /var/run/postgresql" -D $PGDATA
  pgbackrest --stanza=$stanza --pg1-port=$PGPORT \
    --log-level-console=info check
  pgbackrest_check_result=$?

  if [ $pgbackrest_check_result -ne 0 ]; then
    echo "pgbackrest check failed."
    exit $pgbackrest_check_result
  fi

  pg_ctl stop -o "-p $PGPORT -k /var/run/postgresql" -D $PGDATA
fi
