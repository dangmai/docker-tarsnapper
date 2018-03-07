docker-tarsnapper
=================

This is a [Docker](https://www.docker.com/) image for [Tarsnapper](https://github.com/miracle2k/tarsnapper).
When container is run from this image, a cron job is set up in the background,
in order to periodically back up one or multiple directories.
The behavior of this image can be customized by specifying environment variables,
or by mounting files into the container.

Usage
-----
```
docker run -d \
    --name=tarsnapper \
    -v <path to data to back up>:/backup:ro \
    -v <location of tarsnap key>:/tarsnap/key:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "BACKUP_CRON=0 0 * * *" \
    -e "BACKUP_COMMAND=-o v -c /etc/tarsnapper.conf make" \
    dangmai/tarsnapper
```

Parameters
----------

- `-v /backup` - The directory containing the data to back up
- `-v /tarsnap/key` - The private Tarsnap key
- `-v /etc/localtime` - for time sync purpose between the host and the container
- `-e BACKUP_CRON` - The cron expression to describe when the backup job runs.
If not specified, this defaults to a random time daily,
so as not to stress Tarsnap server at once
- `-e BACKUP_COMMAND` - The back up command to use for Tarsnapper.
If not specified, this defaults to `-c /etc/tarsnapper.conf make`

You can use these parameters for simple Tarsnapper backup/expiration.
By default, the deltas is `1d 7d 30d`, and the job name is `mybackup`.
Of course, if you need more customizations for Tarsnapper,
you can always mount your own Tarsnapper config file to `/etc/tarsnapper.conf`.

*Note*: This container runs `tarsnap --fsck` every time Tarsnapper is invoked,
which causes a small amount of metadata download.
This is done in order to keep Tarsnap cache up to date,
no matter when you run the Docker container.
However, the downside is that it'll incur a small charge for the metadata download.

*Note*: Be careful if you want to use environmental variables inside `/etc/tarsnapper.conf`.
By default, `cron` sets up a minimal environment for each command it runs,
so the environmental variables will not show up in `exec-before` or `exec-after`.
You can work around it by creating a custom entry point,
and dump the needed variables into `/etc/environment` for them to be picked up by `cron`.

Restore
-------

In case you need to restore your back up, the following command will do it:

```
docker run --rm -it \
    -v <path to directory to restore to>:/backup \
    -v <location of tarsnap key>/tarsnap/key:ro \
    -v /etc/localtime:/etc/localtime:ro \
    dangmai/tarsnapper \
    sh -c "tarsnap --fsck && tarsnap -pxf <back up name>"
```
