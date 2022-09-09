#!/bin/bash

apt-get update
apt install -y ansible



crontab -l > crontab_new 
cat << EOF >> crontab_new 
5 * * * * /usr/bin/ansible-pull ansible-pull -U git@github.com:sebastian-mora/mcdiscordbot.git  -i hosts  ansible/${ansible_host_name}.yml 2>&1
EOF
crontab -u ubuntu crontab_new
rm crontab_new

