#!/bin/bash

if [ -s ~/.serverfarmer/inventory/collector.hosts ]; then
	for collector in `grep -v ^# ~/.serverfarmer/inventory/collector.hosts`; do

		if [ -z "${collector##*:*}" ]; then
			host="${collector%:*}"
			port="${collector##*:}"
		else
			host=$collector
			port=22
		fi

		colkey=`/opt/farm/ext/keys/get-ssh-dedicated-key.sh $host root`

		if [ "$1" = "" ]; then
			echo "synchronizing backup list with remote collector $collector"
		else
			newkey=`/opt/farm/ext/keys/get-ssh-dedicated-key.sh $1 backup`
			keydir=`dirname $newkey`

			if [ -f $newkey ]; then
				echo "registering server $1 on remote collector $collector"
				scp -B -p -i $colkey -P $port $newkey root@$host:$keydir
			fi
		fi

		scp -B -p -i $colkey -P $port ~/.serverfarmer/inventory/backup.hosts root@$host:/root/.serverfarmer/inventory
	done
fi
