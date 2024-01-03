# `snap_handler_rsync.sh`

This is a simple *snap* handler to sync folders using rsync tool.
Unchanged files are linked (using hard links), so that less space is used.

```bash
Usage: snap_handler_rsync.sh [-c] [-o rsync additional options] [-e rsync_exclude_argument ...] {src_path} {dest_path} {dst_name} [prepare | create ref ... | remove ref | list]

Arguments:
-c       - do not use hard links, copy instead
-o       - pass additional options to rsync
-e exclude - rsync exclude argument (can be set multiple times)
src_path - path to source file or directory
dst_path - path to backup directory
dst_name - prefix of the files/directories inside backup directory
```

## Example: backup home directory

### prepare structure

```bash
sudo mkdir /opt/backup/
sudo mkdir /opt/backup/$(whoami)
sudo chmod $(whoami):$(whoami) /opt/backup/$(whoami)
```

### put handler arguments to the script

```bash
cd
touch runBackup.sh
chmod 755 runBackup.sh
vi runBackup.sh
(replace {user} with real user name)
---
#!/usr/bin/env bash

set -e

/usr/local/bin/snap_handler_rsync.sh \
    -o '-a --chmod=D0770' \
    -e '/.cabal/' \
    -e '/.cache/' \
    -e '/mirror/' \
    -e '/.dbus/' \
    -e '/.local/share/' \
    -e '/.thumbnails/' \
    -e '/.mozilla/' \
    -e '/.qsave/' \
    -e '/virtual/' \
    -e '/iso/' \
    /home/{user}/ \
    /opt/backup/{user} \
    home \
    $@
---
```

### put to user's crontab (at 2AM)

```bash
crontab -e
(add to the end of file, replace {user} with real user name, save file, exit)
0 2 * * * /usr/local/bin/cyclic_backup /home/{user}/runBackup.sh --keep 30 1day --keep 10 10day --keep 10 100day
```

### verify daily backups

```bash
ls -l /opt/backup/$(whoami)
```
