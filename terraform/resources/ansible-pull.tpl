#!/bin/bash

apt-get update
apt install -y ansible

5 * * * * /usr/bin/ansible-pull ansible-pull -U git@github.com:sebastian-mora/mcdiscordbot.git  -i hosts  ansible/${ansible_host_name}.yml
