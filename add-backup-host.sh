#!/bin/bash
. /opt/farm/scripts/functions.net
. /opt/farm/scripts/functions.custom

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname[:port]>"
	exit 1
elif [ "`resolve_host $1`" = "" ]; then
	echo "error: parameter $1 not conforming hostname format, or given hostname is invalid"
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

if grep -qxF $server /etc/local/.farm/backup.hosts; then
	echo "error: server $server already added"
	exit 1
fi

newkey=`ssh_dedicated_key_storage_filename $host backup`
keydir=`dirname $newkey`

if [ ! -f $newkey ]; then
	echo "error: ssh key for backup@$host not found"
	exit 1
fi

echo $server >>/etc/local/.farm/backup.hosts

if [ -s /etc/local/.farm/collector.hosts ]; then
	for collector in `cat /etc/local/.farm/collector.hosts`; do
		echo "registering server $server on remote collector $collector"
		colkey=`ssh_dedicated_key_storage_filename $collector root`
		scp -B -p -i $colkey $newkey root@$collector:$keydir
		scp -B -p -i $colkey /etc/local/.farm/backup.hosts root@$collector:/etc/local/.farm
	done
fi
