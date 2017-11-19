#!/bin/bash

if [ -z "$(ls -A ${DOKUWIKI_ROOT})" ]; then
  echo "Dokuwiki root directory (${DOKUWIKI_ROOT}) is empty, try to restore from backup"
  restore_dokuwiki_from_backup || echo "Backup restore failed, ${DOKUWIKI_ROOT} is still empty"
fi

/usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
