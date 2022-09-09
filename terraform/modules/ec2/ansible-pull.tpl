#!/bin/bash

apt-get update
apt install -y  unzip jq software-properties-common

add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

ansible-galaxy collection install amazon.aws

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

# Save ssh key
/usr/local/bin/aws ssm get-parameter --name "/mc/ssh-deploy-key" --with-decryption --region us-west-2  | jq -r '.Parameter.Value' > /home/ubuntu/.ssh/ssh_deploy
chown ubuntu /home/ubuntu/.ssh/ssh_deploy
chmod 400 /home/ubuntu/.ssh/ssh_deploy

# Get fingerprint for github.com 
ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts


(crontab -u ubuntu -l 2>/dev/null; echo "5 * * * * /usr/bin/ansible-pull -U git@github.com:sebastian-mora/mcdiscordbot.git --only-if-changed --key-file ~/.ssh/ssh_deploy -i hosts  ansible/${ansible_host_name}.yml -v >> ~/ansible-pull-logs") | crontab -u ubuntu -

