#/bin/bash

EXPIRE_COMMAND=${EXPIRE_COMMAND:-"-c /etc/tarsnapper.conf expire"}
export PATH=$PATH:/usr/local/bin
tarsnap --fsck && tarsnapper $EXPIRE_COMMAND
