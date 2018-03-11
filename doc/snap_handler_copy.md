# `snap_handler_copy.sh`

This is a simple *snap* handler to copy files or directories to a specified location.

```bash
Usage: snap_handler_copy.sh {src_path} {dest_path} {dst_name} [prepare | create ref | remove ref | list]

Arguments:
src_path - path to source file or directory
dst_path - path to backup directory
dst_name - prefix of the files/directories inside backup directory
```

## Example

* Create periodic backup of `~/important` file.
* Save backups to `~/backup` directory.
* Use prefix `bkpname` for backups.

## Check handler from command line

```bash
#Create important file in $HOME directory
cd
echo "some data" >> important

# veriy **prepare** action
snap_handler_copy.sh important backup bkpname prepare
ls -l backup

# verify **create** action
snap_handler_copy.sh important backup bkpname create ref1
diff important backup/bkpname@ref1
echo "some more data" >> important
snap_handler_copy.sh important backup bkpname create ref1
snap_handler_copy.sh important backup bkpname create ref2
diff important backup/bkpname@ref2
ls -l backup

# verify **list** and **remove** actions
snap_handler_copy.sh important backup bkpname list
snap_handler_copy.sh important backup bkpname remove ref1
snap_handler_copy.sh important backup bkpname remove ref2
snap_handler_copy.sh important backup bkpname list
ls -l backup
```

## Use handler inside `cyclic_backup`

For this test, use very short period (1 second) and keep 3 intervals.

```bash
cd
cyclic_backup "snap_handler_copy.sh important backup bkpname" --keep 3 1second

# re-run cyclic_backup command several times
# observe if the backups are created and removed
# according to the rules
ls -l backup
```

### Automate the procedure with user's *cron*

For this example, let's create backup every minute and keep:

* 5 last backups (1 minute)
* then 3 backups (2 minutes)
* then 2 backups (4 minutes)


```bash
# append entry in user's cron
crontab -e
<add this content at the end of the file>
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
BASE=/home/$(whoami)

* * * * * cyclic_backup "snap_handler_copy.sh $BASE/important $BASE/backup important" --keep 5 1minute --keep 3 2minute --keep 2 4minute
<save file>
```

