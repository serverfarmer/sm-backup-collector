#!/bin/sh

base="/srv/mounts/backup"
remote="$base/remote"
own="$base/remote/`hostname`"
sets="$base/sets"
current="$base/sets/current"


touch      /etc/local/.farm/backup.hosts
chmod 0600 /etc/local/.farm/backup.hosts

mkdir -p $own
mkdir -p $current

chown backup:backup $remote $own $sets
chmod 0700 $remote $own $sets
chmod 0711 $current

ln -sf /opt/farm/ext/backup-collector/add-backup-host.sh /usr/local/bin/add-backup-host
