sf-backup-collector extension provides central backup functionality for
small and medium server farms.

**Architecture**

1. Each server is responsible for generating its own backup files on daily basis.

2. There is one central backup server, that holds ssh keys for "backup" account
   on all servers.

3. Backup collector runs on the mentioned central backup server, and fetches
   backup files from all remote servers to local storage using scp.

4. Fetched files are stored in hierarchical structure divided by hostnames
   and dates to allow easy further processing by separate business logic
   (not included here).
