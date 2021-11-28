#!/bin/bash
apt-get update
apt install -y unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws cp . s3://${aws_s3_bucket.mc-worlds.name}/scripts

cat crontab >> /etc/crontab