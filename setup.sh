#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-net-utils
/opt/farm/scripts/setup/extension.sh sf-farm-rename

path="/etc/local/.farm"

mkdir -p $path
chmod 0700 $path

touch      $path/backup.hosts $path/collector.hosts
chmod 0600 $path/backup.hosts $path/collector.hosts

base="/srv/mounts/backup"
remote="$base/remote"
sets="$base/sets"
current="$base/sets/current"

mkdir -p $remote
mkdir -p $current

chown backup:backup $remote $sets
chmod 0700 $remote $sets
chmod 0711 $current
