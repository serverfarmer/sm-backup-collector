#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-net-utils

mkdir -p   ~/.serverfarmer/inventory
chmod 0700 ~/.serverfarmer/inventory
touch      ~/.serverfarmer/inventory/backup.hosts ~/.serverfarmer/inventory/collector.hosts
chmod 0600 ~/.serverfarmer/inventory/backup.hosts ~/.serverfarmer/inventory/collector.hosts

base="/srv/mounts/backup"
remote="$base/remote"
sets="$base/sets"
current="$base/sets/current"

mkdir -p $remote
mkdir -p $current

chown backup:backup $remote $sets
chmod 0700 $remote $sets
chmod 0711 $current
