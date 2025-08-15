# Используем официальный образ Ubuntu
FROM ubuntu:22.04

# Установка Nginx
RUN apt-get update && apt-get install -y nginx

# Копируем index.html (можно создать в этой папке)
COPY index.html /var/www/html/index.html

# Открываем порт 80
EXPOSE 80

# Запуск nginx
CMD ["nginx", "-g", "daemon off;"]
