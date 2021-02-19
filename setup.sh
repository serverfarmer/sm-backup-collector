#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-net-utils

mkdir -p   ~/.farm
chmod 0700 ~/.farm
touch      ~/.farm/backup.hosts ~/.farm/collector.hosts
chmod 0600 ~/.farm/backup.hosts ~/.farm/collector.hosts

base="/srv/mounts/backup"
remote="$base/remote"
sets="$base/sets"
current="$base/sets/current"

mkdir -p $remote
mkdir -p $current

chown backup:backup $remote $sets
chmod 0700 $remote $sets
chmod 0711 $current
