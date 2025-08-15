# Automation Notes by Dima

Этот файл содержит мини-статьи и кейсы по автоматизации рутинных задач в системном администрировании и DevOps.

---

## 1. Мониторинг диска

Простейший bash-скрипт для проверки заполненности дисков и уведомления:

```bash
#!/bin/bash
THRESHOLD=80
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | while read output;
do
  usep=$(echo $output | awk '{ print $5 }' | sed 's/%//g')
  partition=$(echo $output | awk '{ print $1 }')
  if [ $usep -ge $THRESHOLD ]; then
    echo "Warning: Partition $partition is at ${usep}% usage."
  fi
done
