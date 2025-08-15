#!/bin/bash
# Настройка UTF-8 для сервера

echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc

source ~/.bashrc

sudo locale-gen en_US.UTF-8
sudo update-locale

echo "UTF-8 локаль настроена ✅"
