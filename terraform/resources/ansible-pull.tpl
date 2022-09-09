#!/bin/bash

apt-get update
apt install -y ansible unzip

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Save ssh key
/usr/local/bin/aws ssm get-parameter --name "/mc/ssh-deploy-key" --with-decryption --region us-west-2  | jq -r '.Parameter.Value' > /home/ubuntu/.ssh/id_rsa
chown ubuntu /home/ubuntu/.ssh/id_rsa
chmod 400 /home/ubuntu/.ssh/id_rsa

crontab -l > crontab_new 
cat << EOF >> crontab_new 
5 * * * * /usr/bin/ansible-pull ansible-pull -U git@github.com:sebastian-mora/mcdiscordbot.git  -i hosts  ansible/${ansible_host_name}.yml 2>&1
EOF
crontab -u ubuntu crontab_new
rm crontab_new

