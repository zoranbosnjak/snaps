# `zfs_snap_sync`

Sync zfs snapshots between computers.

This program compares snapshot listing between 2 computers (`zfs list -t snapshot -o name | grep {snapshot pattern}`).
If a common snapshot is found, it would then:
    * remove extra snapshots on the destination side,
    * copy over missing snapshots from the source to the destination side.

The program can run in:
    * *push* mode (local side is source, remote side is destination)
    * *pull* mode (remote side is source, local side is destination)

Zfs sync is performed in *incremental mode*, so the first sync must be performed by manually, before running this program.

## Examples:

```bash
sudo ./zfs_snap_sync push --src "datapool/test" --snapshot "cyclic-" --dst "datapool/zbak_srv1-test" -e "ssh remote1" -v
sudo ./zfs_snap_sync pull --src "datapool/test" --snapshot "cyclic-" --dst "datapool/zbak_srv2-test" -e "ssh remote2" -v
```

