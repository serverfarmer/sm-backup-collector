#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-net-utils

base="/srv/mounts/backup"
remote="$base/remote"
sets="$base/sets"
current="$base/sets/current"

touch      /etc/local/.farm/backup.hosts /etc/local/.farm/collector.hosts
chmod 0600 /etc/local/.farm/backup.hosts /etc/local/.farm/collector.hosts

mkdir -p $remote
mkdir -p $current

chown backup:backup $remote $sets
chmod 0700 $remote $sets
chmod 0711 $current

ln -sf /opt/farm/ext/backup-collector/add-backup-host.sh /usr/local/bin/add-backup-host
