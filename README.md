# Server Farmer backup collector

### Overview

Distributed backup is one of the key functionalities of Server Farmer.

All hosts with installed Server Farmer, unless explicitly disabled, are doing their own backup (to specified directory on local drive, using `sf-backup` extension), which is then pulled using `scp` by *backup collector* host (which is responsible for long-term backup storage).

*This part of backup documentation describes only collector/storage aspects. See `sf-backup` repository for details about the backup process itself.*


### Adding new servers to backup collector

New servers are added using `add-backup-host.sh` script, which requires that added server has already installed dedicated ssh key for `backup` system user.

Usually all this process is wrapped by `add-managed-host.sh` script from `sm-farm-manager` extension, which is the primary script for adding new servers to the farm.


### Types of backup collectors

There are 4 types of backup collectors:

1. Standalone - in this default scenario, *farm manager* is also the only backup collector (except possibly blind slaves). It is responsible for:
- managing `backup.hosts` file (and associated ssh keys)
- fetching backup archives from managed hosts
- all possible further actions on fetched backups (statistics, transformations etc. - out of scope)

2. Master - responsible only for the management part, while `backup.hosts` and ssh keys are sent to slave collector(s) after each update, using `sync-remote-collectors.sh` script.

3. Slave - responsible only for actual fetching backup archives and further processing. Registered in `collector.hosts` file on master collector. Typically there is only one slave collector (all of them share the same `backup.hosts` file and would fetch the same data, so multiple slaves are mostly used in tricky and very rare network setups).

4. Blind slave - like slave, but not registered in `collector.hosts` file, instead updated manually, and responsible for backups of some group of servers only. Such configuration is used mainly for commercial customers, who want to have all their backup stored in separate place.


### `backup.hosts` file format

`backup.hosts` (as well as `collector.hosts`) is simply a text file with list of hostnames, possibly including port numbers, one per line:

```
hostname1.internal:22
hostname2.internal
otherserver.domain.com:3322
```

Empty lines and lines starting with `#` character are ignored.


### How backup collector backups itself

Backup collector, just like any other host, is responsible for its own backup.

Then, if its hostname is found in `backup.hosts` file, its backup is moved locally (instead of `scp`) to storage directory tree.

In some special scenarios, you can remove backup collector hostname from `backup.hosts` file (this is used mostly in high-compliance setups, in combination with `push-to-collector` (where *farm manager* and backup collector are sending their own encrypted backups to another host).


### Backup storage directory tree format

All fetched backup archives are stored inside `/srv/mounts/backup/remote` directory (you can't change it, but it can be a symlink). Default directory tree structure looks like this:

```
/srv/mounts/backup/remote/otherserver.domain.com/20180902/etc.tar.gpg
                          ^                      ^        ^
                          hostname (no port)     date     file
```

If this is not enough, since you eg. need to store backups from each hour, you can extend this structure using `/etc/local/.config/backup.index` file, which should contain the date mask, eg.:

```
%Y%m%d/%H
```


### Backup transfer process

Backup collector fetches backup files from remote hosts using `scp` and dedicated ssh keys (separate key for each host), for `backup` system user.


### Push-to-collector mode

In default scenario, backup collector has full shell access to managed hosts, as `backup` system user, including to *farm manager*. In high-compliance setups, eg. PCI DSS, this is not acceptable, as this is just one step away from having access to management ssh keys located on *farm manager*.

Because of that, script `cron/push-to-collector.sh` in `sf-backup` extension allows transferring farm manager encrypted backups in other direction: from farm manager to backup collector. This way, backup collector no longer needs ssh access to farm manager, which .
