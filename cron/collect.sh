#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.keys
# this script collects encrypted backup files created
# by Server Farmer cron scripts from remote machines
# Tomasz Klim, 2013-2017


function get_directory() {
	path=$1
	host=$2
	date=$3
	if [ "$4" = "custom" ]; then
		base="$path/CUSTOM-$host"
	else
		base="$path/$host"
	fi
	out="$base/$date"
	if [ -d $base ] || [ -h $base ]; then
		if [ ! -d $out ]; then
			mkdir -p -m 0700 $out
		fi
	fi
	echo $out
}


db="/etc/local/.farm/backup.hosts"

base="`local_backup_directory`"
path="/srv/mounts/backup/remote"

if [ ! -d $path ] || [ ! -f $db ]; then
	echo "error: backup is not configured yet"
	exit 1
fi

if [ "$1" != "--all" ]; then
	groups="daily"
else
	groups="daily weekly custom"
fi

index=`backup_history_index`
date=`date +$index`
host=`hostname`

for group in $groups; do
	target=`get_directory $path $host $date $group`
	mv $base/$group/* $target
done

for server in `cat $db |grep -v ^#`; do
	if [ -z "${server##*:*}" ]; then
		host="${server%:*}"
		port="${server##*:}"
	else
		host=$server
		port=22
	fi
	for group in $groups; do
		sshkey=`ssh_dedicated_key_storage_filename $host backup`
		target=`get_directory $path $host $date $group`
		scp -B -p -i $sshkey -P $port backup@$host:$base/$group/* $target
	done
done
