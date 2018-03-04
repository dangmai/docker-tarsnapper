#!/bin/bash
GLOBIGNORE="*"

RANDOM_BACKUP_HOUR=`shuf -i 0-23 -n 1`
RANDOM_EXPIRE_HOUR=`shuf -i 0-23 -n 1`
RANDOM_BACKUP_MINUTE=`shuf -i 1-59 -n 1`
RANDOM_EXPIRE_MINUTE=`shuf -i 1-59 -n 1`

BACKUP_CRON=${BACKUP_CRON:-"$RANDOM_BACKUP_MINUTE $RANDOM_BACKUP_HOUR * * *"}
EXPIRE_CRON=${EXPIRE_CRON:-"$RANDOM_EXPIRE_MINUTE $RANDOM_EXPIRE_HOUR * * *"}
BACKUP_COMMAND=${BACKUP_COMMAND:-"-c /etc/tarsnapper.conf make"}
EXPIRE_COMMAND=${EXPIRE_COMMAND:-"-c /etc/tarsnapper.conf expire"}

cat << EOF > /etc/cron.d/tarsnapper
$BACKUP_CRON root BACKUP_COMMAND="${BACKUP_COMMAND}" /tarsnapper-backup.sh >> /var/log/cron.log 2>&1
$EXPIRE_CRON root EXPIRE_COMMAND="${EXPIRE_COMMAND}" /tarsnapper-expire.sh >> /var/log/cron.log 2>&1

EOF

chmod 0644 /etc/cron.d/tarsnapper
touch /var/log/cron.log

cron && tail -f /var/log/cron.log
