#!/bin/bash
. /opt/farm/scripts/functions.custom


db="/etc/local/.config/backup.hosts"

base="`local_backup_directory`"
path="$base/remote"


if [ "$1" = "" ]; then
	echo "usage: $0 <hostname[:port]>"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9.-]+[.][a-z0-9]+([:][0-9]+)?$ ]]; then
	echo "error: parameter $1 not conforming hostname format"
	exit 1
fi

server=$1
if [ -z "${server##*:*}" ]; then
	host="${server%:*}"
	port="${server##*:}"
else
	host=$server
	port=22
fi

if [ "`getent hosts $host`" = "" ]; then
	echo "error: host $host not found"
	exit 1
elif [ -d $path/$host ]; then
	echo "error: host $host already added"
	exit 1
fi

sshkey=`ssh_dedicated_key_storage_filename $host backup`
ssh -i $sshkey -p $port -o StrictHostKeyChecking=no -o PasswordAuthentication=no backup@$host uptime >/dev/null 2>/dev/null

if [[ $? != 0 ]]; then
	echo "error: host $server denied access"
	exit 1
fi

mkdir $path/$host
chown backup:backup $path/$host
chmod 0700 $path/$host

echo $server >>$db
