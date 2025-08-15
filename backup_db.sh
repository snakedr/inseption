#!/bin/bash
DATE=$(date +%F)
BACKUP_DIR="/var/backups/postgres"
mkdir -p $BACKUP_DIR
pg_dumpall -U postgres > $BACKUP_DIR/db_backup_$DATE.sql
