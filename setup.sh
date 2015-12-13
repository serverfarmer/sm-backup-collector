#!/bin/bash
. /opt/farm/scripts/functions.custom


db="/etc/local/.config/backup.hosts"

base="`local_backup_directory`"
remote="$base/remote"
own="$base/remote/`hostname`"
sets="$base/sets"
current="$base/sets/current"


config="`dirname $db`"
mkdir -p $config
chmod 0700 $config

touch $db
chmod 0600 $db

mkdir -p $own
mkdir -p $current

chown backup:backup $remote $own $sets
chmod 0700 $remote $own $sets
chmod 0711 $current

ln -sf /opt/sf-backup-collector/add-backup-host.sh /usr/local/bin/add-backup-host
