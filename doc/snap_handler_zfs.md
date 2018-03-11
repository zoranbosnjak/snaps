# `snap_handler_zfs.sh`

This is a simple *snap* handler to manage *ZFS* filesystem snapshots.

```bash
Usage: snap_handler_zfs.sh {dataset} [prepare | create ref | remove ref | list]

Arguments:
dataset - name of the zfs dataset
```

## Example

Create a snapshot of dataset `datapool/test`.

## Check handler from command line

```bash

# create the dataset if it does not exist already
sudo zfs create datapool/test -o mountpoint=/mnt/test

# check existence of the dataset
sudo zfs list -o name | grep datapool/test

# ... and no snapshots yet
sudo zfs list -t snapshot -o name | grep datapool/test
sudo snap_handler_zfs.sh datapool/test list

# check zfs handler (create action, list action)
sudo snap_handler_zfs.sh datapool/test create ref1
sudo zfs list -t snapshot -o name | grep datapool/test
sudo snap_handler_zfs.sh datapool/test list

# check zfs handler (remove action, list action)
sudo snap_handler_zfs.sh datapool/test remove ref1
sudo zfs list -t snapshot -o name | grep datapool/test
sudo snap_handler_zfs.sh datapool/test list
```

## Automate with *cron*

For example:

* use *hourly* backup
* keep 10 hourly snapshots
* and 3 snapshots 10 hours apart
* and 2 snapshots 100 hours apart

Create file, make executable:

```bash
sudo touch /etc/cron.hourly/do_cyclic_backup
sudo chmod 755 /etc/cron.hourly/do_cyclic_backup
```
Put the following content to `/etc/cron.hourly/do_cyclic_backup`:

```bash
#!/bin/sh

path=/usr/local/bin

$path/cyclic_backup "$path/snap_handler_zfs.sh datapool/test" --keep 10 1hour --keep 3 10hour --keep 2 100hour
```

Restart cron (if necessary):

```bash
sudo service cron restart
```
