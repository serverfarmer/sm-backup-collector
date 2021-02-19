#!/bin/bash


function get_directory() {
	path=$1
	host=$2
	date=$3
	if [ "$4" = "custom" ]; then
		base="$path/CUSTOM-$host"
	else
		base="$path/$host"
	fi
	if [ ! -d $base ] && [ ! -h $base ]; then
		mkdir -m 0700 $base
		chown backup:backup $base
	fi
	if [ ! -d $base/$date ]; then
		mkdir -p -m 0700 $base/$date
	fi
	echo $base/$date
}


base="`/opt/farm/config/get-local-backup-directory.sh`"
path="/srv/mounts/backup/remote"

if [ ! -d $path ] || [ ! -f ~/.farm/backup.hosts ]; then
	echo "error: backup is not configured yet"
	exit 1
fi

if [ "$1" != "--all" ]; then
	groups="daily"
else
	groups="daily weekly custom"
fi

if [ -s /etc/local/.config/backup.index ]; then
	index="`cat /etc/local/.config/backup.index`"
else
	index="%Y%m%d"
fi

date=`date +$index`
ownhost=`hostname`

if grep -qxF $ownhost ~/.farm/backup.hosts; then
	for group in $groups; do
		target=`get_directory $path $ownhost $date $group`
		mv $base/$group/* $target
	done
fi

for server in `grep -v ^# ~/.farm/backup.hosts |grep -vxF $ownhost`; do
	if [ -z "${server##*:*}" ]; then
		host="${server%:*}"
		port="${server##*:}"
	else
		host=$server
		port=22
	fi
	for group in $groups; do
		sshkey=`/opt/farm/ext/keys/get-ssh-dedicated-key.sh $host backup`
		target=`get_directory $path $host $date $group`
		scp -B -p -i $sshkey -P $port -o StrictHostKeyChecking=no -o PasswordAuthentication=no backup@$host:$base/$group/* $target
	done
done
