#!/bin/bash
# monitor_disk.sh
# Скрипт проверяет заполненность дисков и предупреждает, если выше порога

THRESHOLD=80  # порог заполненности в процентах

# Проверяем все разделы кроме tmpfs и cdrom
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | while read output;
do
  usep=$(echo $output | awk '{ print $5 }' | sed 's/%//g')
  partition=$(echo $output | awk '{ print $1 }')
  if [ $usep -ge $THRESHOLD ]; then
    echo "Warning: Partition $partition is at ${usep}% usage."
  fi
done
