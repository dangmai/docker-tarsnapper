#/bin/bash

export PATH=$PATH:/usr/local/bin
tarsnap --fsck && tarsnapper $BACKUP_COMMAND
