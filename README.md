# tar-backup

This is a basic backup management image. It periodically tar's a directory and rotates the backups. It can optionally pause docker containers before doing the backup.

The base image is based on [LinuxServer.io](https://www.linuxserver.io/).

The backup rotation uses [xolox/python-rotate-backups](https://github.com/xolox/python-rotate-backups).

## Command

```bash
docker run -d --network none \
    -e TZ=America/Toronto \
    -e PUID=1000 \
    -e PGID=1000 \
    -e UMASK_SET=027 \
    -v $(PWD)/backup-config:/config \
    -v /host/path/to/data:/data:ro \
    -v /host/path/to/backup:/backup \
    ghcr.io/Chris-V/tar-backup
```

After the first run, sample configs will be added to your `config` volume. Change the content to your liking and restart the container.

Make sure the user specified can read `data` and write to `backup`.

## Variables

Env. var | Default | Description
---|---|---
CRONTAB | 0 3 * * * | The cron schedule used to run backups.
PAUSE_CONTAINERS | | A space separated list of docker containers to pause before a backup.
PAUSE_CONTAINERS_WAIT_SECONDS | 10 | Seconds to wait after pausing the containers.
PUID | 911 | User id. See [LinuxServer.io](https://docs.linuxserver.io/general/understanding-puid-and-pgid) for more.
PGID | 911 | Group id. See [LinuxServer.io](https://docs.linuxserver.io/general/understanding-puid-and-pgid) for more.
UMASK_SET | 022 | `umask` to apply before starting the processes.
