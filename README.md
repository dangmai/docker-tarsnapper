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
    -e "EXPIRE_CRON=10 0 * * *" \
    -e "BACKUP_COMMAND=-o v -c /etc/tarsnapper.conf make" \
    -e "EXPIRE_COMMAND=-o v -c /etc/tarsnapper.conf expire" \
    -e "JOB_NAME=<back up name>" \
    -e "DELTA=1d 7d 30d 360d 18000d" \
    dangmai/tarsnapper
```

* Parameters

- `-v /backup` - The directory containing the data to back up
- `-v /tarsnap/key` - The private Tarsnap key
- `-v /etc/localtime` - for time sync purpose between the host and the container
- `-e BACKUP_CRON` - The cron expression to describe when the backup job runs.
If not specified, this defaults to a random time daily,
so as not to stress Tarsnap server at once
- `-e EXPIRE_CRON` - The cron expression to describe when the expire job runs.
If not specified, this defaults to a random time daily,
so as not to stress Tarsnap server at once
- `-e BACKUP_COMMAND` - The back up command to use for Tarsnapper.
If not specified, this defaults to `-c /etc/tarsnapper.conf make`
- `-e EXPIRE_COMMAND` - The expire command to use for Tarsnapper.
If not specified, this defaults to `-c /etc/tarsnapper.conf expire`
- `-e JOB_NAME` - The back up job name. This defaults to `mybackup`
- `-e DELTA` - The delta to use for Tarsnapper.
If not specified, this defaults to `1d 7d 30d`

You can use these parameters for simple Tarsnapper backup/expiration.
Of course, if you need more customizations for Tarsnapper,
you can always mount your own Tarsnapper config file to `/etc/tarsnapper.conf`.

*Note*: This container runs `tarsnap --fsck` every time Tarsnapper is invoked,
which causes a small amount of metadata download.
This is done in order to keep Tarsnap cache up to date,
no matter when you run the Docker container.
However, the downside is that it'll incur a small charge for the metadata download.

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