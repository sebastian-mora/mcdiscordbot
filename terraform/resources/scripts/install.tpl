#!/bin/bash
apt-get update
apt install -y unzip openjdk-17-jdk wget

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Download server
mkdir /home/ubuntu/server
mkdir /home/ubuntu/scripts
wget -O /home/ubuntu/server/server.jar ${url}
echo "eula=true" > /home/ubuntu/server/eula.txt
chmod +x /home/ubuntu/server/server.jar

# Pull scripts
aws s3 sync s3://${bucket}/ /home/ubuntu/scripts

# Setup minecraft service
cat << EOF > /etc/systemd/system/minecraft@.service 
[Unit]
Description=Minecraft Server: %i
After=network.target

[Service]
WorkingDirectory=/home/ubuntu/server/%i
Restart=always
ExecStart=/usr/bin/screen -DmS mc-%i /usr/bin/java -Xmx4G -jar /home/ubuntu/server/server.jar nogui

EOF

systemctl start minecraft@survival
systemctl enable minecraft@survival

# Enable crontab
cat /home/ubuntu/server/crontab >> /etc/crontab