#!/bin/bash
apt-get update
apt install -y unzip default-jdk wget

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Download server
mkdir server
wget -O ./server/server.jar https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar
echo "eula=true" > ./server/eula.txt

# Pull scripts
aws s3 cp s3://${aws_s3_bucket.mc-worlds.name}/scripts/ .

# Setup minecraft service

# Enable crontab
cat crontab >> /etc/crontab