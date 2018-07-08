#!/bin/sh
. /opt/farm/scripts/functions.custom

if [ -s /etc/local/.farm/collector.hosts ]; then
	for collector in `cat /etc/local/.farm/collector.hosts |grep -v ^#`; do

		if [ -z "${collector##*:*}" ]; then
			host="${collector%:*}"
			port="${collector##*:}"
		else
			host=$collector
			port=22
		fi

		colkey=`ssh_dedicated_key_storage_filename $host root`

		if [ "$1" = "" ]; then
			echo "synchronizing backup list with remote collector $collector"
		else
			newkey=`ssh_dedicated_key_storage_filename $1 backup`
			keydir=`dirname $newkey`

			if [ -f $newkey ]; then
				echo "registering server $1 on remote collector $collector"
				scp -B -p -i $colkey -P $port $newkey root@$host:$keydir
			fi
		fi

		scp -B -p -i $colkey -P $port /etc/local/.farm/backup.hosts root@$host:/etc/local/.farm
	done
fi