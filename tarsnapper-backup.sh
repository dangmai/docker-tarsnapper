#/bin/bash

BACKUP_COMMAND=${BACKUP_COMMAND:-"-c /etc/tarsnapper.conf make"}
export PATH=$PATH:/usr/local/bin
tarsnap --fsck && tarsnapper $BACKUP_COMMAND
