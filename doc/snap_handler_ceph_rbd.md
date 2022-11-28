# Backup CEPH images

Example:

```
$ sudo rbd -p libvirt-pool ls
rbd-image1
rbd-image2
```

```bash
sudo mkdir -p /opt/ceph-backup
sudo cp snap_handler_ceph_rbd.sh /opt/ceph-backup
sudo cp cyclic_backup /opt/ceph-backup
sudo cp do_cyclic_backup /etc/cron.hourly/
```

... where `do_cyclic_backup` is:

```bash
#!/bin/sh

hnd () { echo "/opt/ceph-backup/snap_handler_ceph_rbd.sh libvirt-pool $1"; }

/opt/ceph-backup/cyclic_backup \
    --time-guard GT "02:00:00" --time-guard LT "04:00:00" \
    --keep 2 1day --keep 2 4day --keep 1 30day \
    "$(hnd rbd-image1)"

/opt/ceph-backup/cyclic_backup \
    --time-guard GT "05:00:00" --time-guard LT "07:00:00" \
    --keep 2 1day --keep 2 4day --keep 1 30day \
    "$(hnd rbd-image2)"
```

