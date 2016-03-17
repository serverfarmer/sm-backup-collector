#!/bin/bash
. /opt/farm/scripts/functions.custom


path="/etc/local/.config"
files="$path/backup.hosts $path/mikrotik.hosts"

base="`local_backup_directory`"
remote="$base/remote"
own="$base/remote/`hostname`"
sets="$base/sets"
current="$base/sets/current"


for db in $files; do
	touch $db
	chmod 0600 $db
done

mkdir -p $own
mkdir -p $current

chown backup:backup $remote $own $sets
chmod 0700 $remote $own $sets
chmod 0711 $current

ln -sf /opt/farm/ext/backup-collector/add-backup-host.sh /usr/local/bin/add-backup-host
