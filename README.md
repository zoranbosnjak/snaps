# Introduction

`cyclic_backup` script creates periodic backups and recycle them, according to the given rules. Assuming that you can *create* and *remove* a single backup, this script will help you to:

* create *periodic* backups
* remove old backups
* keep required number of backups
* handle different backup periods

`cyclic_backup` by itself does not know how to create or remove a backup. It calls an external *handler* to perform the actions. With this mechanism, it is easy to extend the process to run complex backup actions.

## Backup periods

In addition to *basic* backup period, the script is also able to maintain multiple levels of periodicity. For example, it is possible to maintain (at the same time):

* some number of *daily* backups (basic period)
* then some other number of *weekly* backups (higher period)
* then some yet another number of *monthly* backups (higher period - second order)
* ...

## How it works

Process is devided into 2 separate roles:

1. Main `cyclic_backup` script (takes care of backup periodicity).
2. Handler script (takes care of actual backup creation).

A handler script must support the following actions (command line arguments):

* `prepare` to prepare a structure
* `create {ref}` to create a backup with the name `{ref}`
* `remove {ref}` to remove a backup with the name `{ref}`
* `list` to get the listing of existing backups

It is assumed that the `cyclic_backup` script is called periodically (for example from `cron`). On each call, the following actions are performed:

* get current time
* prepare backup structure
* get listing of existing backups
* stop if called too soon
* create new backup
* remove backups that are not needed any more (check all required periods)

This process does not require any database or other storage for backup history. Instead, it checks for existing backups on each call. Depending on current time and backup listing, the script might create a new backup and remove some old backup(s).

Timing requirement is not strict. In general, the script may be called at any time. If the script is called too soon, it will simply skip the backup creation for the next iterration. If the script is called too late, it won't be able to keep up with required backup period. The required number of backups will be maintained in any case. As a consequence of this algorythm, the resulting timing (spacing between backups) is in general not exact.

Optimal backup timing is achieved when:

* Calling period is equal to backup period.
* If higher periods are required, they shall be multiple of the lower order period. For example, daily call with the rule: (3-times 1 day, 4-times 10 days, 5-times 50 days) is OK, since 50 days is multiple of 10 days, which is multiple of 1 day.

# Installation

The script does not require any complex installation. It is sufficient to copy the script and handlers to some known location, for example:

```bash
sudo cp cyclic_backup /usr/local/bin
sudo cp handlers/* /usr/local/bin
```

# Usage and activation

Either:

* Run script periodically from command line;
* Or create *cron* rule(s).

Usage:
```bash
cyclic_backup "{handler args}" --keep {cnt} {interval} ...
```
Example:
```bash
/usr/local/bin/cyclic_backup "/usr/local/bin/snap_handler_zfs.sh datapool/test" --keep 4 1day --keep 3 2day
```

# Examples:

* [file or directory copy handler][handler_copy]
* [*zfs* filesystem snapshot handler][handler_zfs]

# Writing custom handler

A handler is any script or executable which supports required set of actions (command line arguments). The handler must return:

* status `0` when the action was successfull
* other status value in case of error

The *handler* is executed as regular bash string with *action* argument *appended* at the end of the string. So, if the handler requires additional arguments, they shall be processed *before* the *action* argument. General command line form is:
```bash
handler_script [args] {action}
```

## Handler actions

Each handler shall support the following actions:

* `prepare`: Prepare backup structure.
* `create {ref}`: Create a backup with the name `{ref}`.
* `remove {ref}`: Remove a backup with the name `{ref}`.
* `list`: List existing backups, output one `{ref}` per line.

## Simple handler example

We want to backup a single file `/tmp/test.txt` to `/tmp/backup`. Let's call the handler `test_handler.sh`. The following minimal shell script will do:

```bash
---- test_handler.sh
#!/usr/bin/env bash

case $1 in
    "prepare")
        mkdir -p /tmp/backup
        ;;
    "create")
        cp /tmp/test.txt /tmp/backup/test.txt@$2
        ;;
    "remove")
        rm /tmp/backup/test.txt@$2
        ;;
    "list")
        ls /tmp/backup/ | grep "test.txt@" | sed 's/.*@//'
        ;;

    *)
        exit 1
        ;;
esac
----
```

## Testing a simple test handler

```bash
chmod 755 test_handler.sh
touch /tmp/test.txt
./test_handler.sh prepare
./test_handler.sh create ref1
ls -l /tmp/backup
./test_handler.sh list
./test_handler.sh remove ref1
rm /tmp/test.txt
rmdir /tmp/backup
```

[handler_copy]: ./doc/snap_handler_copy.md
[handler_zfs]: ./doc/snap_handler_zfs.md
