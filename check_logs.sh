#!/bin/bash
LOG_FILE="/var/log/syslog"
grep -i "error" $LOG_FILE | tail -n 50
