#!/bin/bash
. /opt/farm/scripts/functions.custom
# this script collects encrypted backup files created
# by Server Farmer cron scripts from remote machines
# Tomasz Klim, 2013-2015


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
	if [ -d $base ] && [ ! -d $out ]; then
		mkdir -m 0700 $out
	fi
	echo $out
}


db="/etc/local/.config/backup.hosts"

base="`local_backup_directory`"
path="$base/remote"

if [ ! -d $path ] || [ ! -f $db ]; then
	echo "error: backup is not configured yet"
	exit 1
fi

if [ "$1" != "--all" ]; then
	groups="daily"
else
	groups="daily weekly custom"
fi

date=`date +%Y%m%d`
host=`hostname`

for group in $groups; do
	target=`get_directory $path $host $date $group`
	mv $base/$group/* $target
done

for host in `cat $db`; do
	for group in $groups; do
		sshkey=`ssh_management_key_storage_filename $host`
		target=`get_directory $path $host $date $group`
		scp -B -p -i $sshkey backup@$host:$base/$group/* $target
	done
done
