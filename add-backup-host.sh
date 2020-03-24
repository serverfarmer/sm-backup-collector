#!/bin/bash
. /opt/farm/ext/net-utils/functions

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

newkey=`/opt/farm/ext/keys/get-ssh-dedicated-key.sh $host backup`

if [ ! -f $newkey ]; then
	echo "error: ssh key for backup@$host not found"
	exit 1
fi

echo $server >>/etc/local/.farm/backup.hosts

if [ -s /etc/local/.farm/collector.hosts ]; then
	/opt/farm/mgr/backup-collector/sync-remote-collectors.sh $host
fi
