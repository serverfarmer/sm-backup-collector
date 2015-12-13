#!/bin/bash
. /opt/farm/scripts/functions.custom


db="/etc/local/.config/backup.hosts"

base="`local_backup_directory`"
path="$base/remote"


if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9.-]+[.][a-z]+$ ]]; then
	echo "error: parameter $1 not conforming hostname format"
	exit 1
elif [ "`getent hosts $1`" = "" ]; then
	echo "error: host $1 not found"
	exit 1
elif [ -d $path/$1 ]; then
	echo "error: host $1 already added"
	exit 1
fi

mkdir $path/$1
chown backup:backup $path/$1
chmod 0700 $path/$1

echo $1 >>$db

sshkey=`ssh_management_key_storage_filename $1`
ssh -i $sshkey -o StrictHostKeyChecking=no root@$1 uptime
