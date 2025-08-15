# 🖥️ Полезные команды Linux (Wiki)

Справочник основных команд Linux для ежедневной работы системного администратора и DevOps-инженера.

---

## 1️⃣ Работа с файлами и каталогами

```bash
ls -lah                # Список файлов с подробной информацией
cd /path               # Перейти в каталог
mkdir new_dir          # Создать каталог
rm file                # Удалить файл
rm -rf dir             # Удалить каталог и всё внутри
cp source dest         # Копировать файл/каталог
mv source dest         # Переместить или переименовать
```

---

## 2️⃣ Просмотр и редактирование файлов

```bash
cat file               # Просмотр содержимого
less file              # Постраничный просмотр
nano file              # Редактирование в nano
vim file               # Редактирование в vim
head file              # Первые строки файла
tail file              # Последние строки файла
tail -f file           # Смотреть лог в реальном времени
```

---

## 3️⃣ Проверка состояния системы

```bash
uptime                 # Время работы и нагрузка
top                    # Просмотр процессов и нагрузки
htop                   # Улучшенный top
free -h                # Использование памяти
df -h                  # Использование дисков
du -sh folder          # Размер папки
```

---

## 4️⃣ Мониторинг процессов

```bash
# 15 процессов с наибольшим потреблением памяти
ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 15

# 15 процессов с наибольшим потреблением CPU
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 15

# Проверка процессов конкретного пользователя
ps -u username -o pid,ppid,%cpu,%mem,cmd

# Убить процесс по PID
kill PID

# Убить процесс по имени
killall process_name

# Найти процесс по имени
pgrep process_name
```

---

## 5️⃣ Права и пользователи

```bash
whoami                 # Текущий пользователь
id user                # Информация о пользователе
chmod 755 file         # Права на файл
chown user:group file  # Смена владельца
sudo command           # Выполнение с правами root
su - username          # Переключиться на другого пользователя
```

---

## 6️⃣ Работа с сетью

```bash
ping host              # Проверка доступности
ifconfig               # Настройка и просмотр интерфейсов (устаревший)
ip addr                # Современный аналог ifconfig
netstat -tulnp         # Просмотр открытых портов и процессов
ss -tulnp              # Современный аналог netstat
ssh user@host          # Подключение по SSH
scp file user@host:/path # Копирование файлов по SSH

# Проверка открытых портов
nmap localhost

# Скачивание файлов
wget url
curl -O url
```

---

## 7️⃣ Журналы и службы

```bash
systemctl status service_name   # Статус службы
systemctl start service_name    # Запуск службы
systemctl stop service_name     # Остановка службы
systemctl restart service_name  # Перезапуск службы
systemctl enable service_name   # Автозагрузка службы
systemctl disable service_name  # Отключить автозагрузку

# Просмотр логов
journalctl -u service_name      # Логи конкретной службы
journalctl -f                   # Следить за логами в реальном времени
journalctl --since "1 hour ago" # Логи за последний час

# Традиционные логи
tail -f /var/log/syslog         # Системные логи
tail -f /var/log/auth.log       # Логи аутентификации
```

---

## 8️⃣ Архивирование и бэкапы

```bash
# Создание архива
tar -czvf archive.tar.gz folder/

# Распаковка архива
tar -xzvf archive.tar.gz

# Просмотр содержимого архива без распаковки
tar -tzvf archive.tar.gz

# Синхронизация файлов с прогрессом
rsync -av --progress source/ destination/

# Создание zip архива
zip -r archive.zip folder/

# Распаковка zip
unzip archive.zip
```

---

## 9️⃣ Пользователи и пароли

```bash
# Добавление нового обычного пользователя
sudo adduser newuser

# Установить пароль
sudo passwd newuser

# Добавление пользователя с правами sudo (root-права)
sudo adduser adminuser
sudo usermod -aG sudo adminuser
sudo passwd adminuser

# Смена пароля существующего пользователя
sudo passwd username

# Просмотр пользователей в системе
cut -d: -f1 /etc/passwd

# Проверка групп пользователя
groups username

# Удаление пользователя
sudo userdel username

# Удаление пользователя с домашней папкой
sudo userdel -r username
```

---

## 🔟 Поиск файлов и текста

```bash
# Найти файл по имени
find /path -name "filename"

# Найти файлы по размеру больше 100MB
find /path -size +100M

# Найти файлы, модифицированные за последние 7 дней
find /path -mtime -7

# Найти и удалить файлы старше 30 дней
find /path -mtime +30 -delete

# Поиск текста в файлах
grep "text" file.txt
grep -r "text" /path/       # Рекурсивный поиск
grep -i "text" file.txt     # Без учета регистра

# Найти процесс
ps aux | grep process_name
```

---

## 1️⃣1️⃣ Управление дисками

```bash
# Просмотр дисков и разделов
lsblk
fdisk -l

# Монтирование диска
sudo mount /dev/sdb1 /mnt/disk

# Размонтирование
sudo umount /mnt/disk

# Проверка файловой системы
sudo fsck /dev/sdb1

# Просмотр использования инодов
df -i
```

---

## 1️⃣2️⃣ Переменные окружения

```bash
# Просмотр всех переменных
env

# Установка переменной
export VAR_NAME="value"

# Добавление в PATH
export PATH=$PATH:/new/path

# Постоянное добавление в ~/.bashrc
echo 'export VAR_NAME="value"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🛠️ Полезные комбинации клавиш

| Комбинация | Описание |
|------------|----------|
| `Ctrl+C` | Прервать выполнение команды |
| `Ctrl+Z` | Приостановить процесс |
| `Ctrl+D` | Выйти из терминала/сессии |
| `Ctrl+L` | Очистить экран |
| `Ctrl+R` | Поиск в истории команд |
| `Tab` | Автодополнение |
| `!!` | Повторить последнюю команду |
| `!n` | Повторить команду номер n |

---

## 📝 Советы

1. **Используйте `man`** для получения справки: `man command_name`
2. **Будьте осторожны с `rm -rf`** - команда необратима
3. **Проверяйте синтаксис** перед выполнением критических команд
4. **Делайте бэкапы** важных файлов перед изменениями
5. **Изучайте логи** при возникновении проблем

---

## 📚 Дополнительные ресурсы

- [Linux Command Line Cheat Sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/)
- [ExplainShell](https://explainshell.com/) - объяснение команд Linux
- [Man Pages Online](https://man7.org/linux/man-pages/)

---

## 🤝 Участие в разработке

Предложения по дополнению и улучшению справочника приветствуются через Issues и Pull Requests.

---

## 📄 Лицензия

MIT License - свободное использование и модификация.