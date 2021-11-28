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

# Pull latest world

# Setup S3 Backup script
export S3_BUCKET=${bucket}
export BACKUP_LIMIT=3
export SNS_TOPIC=${sns_topic}


# Setup minecraft service
cat << EOF > /etc/systemd/system/minecraft@.service 
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/home/ubuntu/server
Restart=always
ExecStart=/usr/bin/screen -DmS mc-%i /usr/bin/java -Xmx4G -jar /home/ubuntu/server/server.jar nogui

EOF

systemctl start minecraft@survival
systemctl enable minecraft@survival

# Enable crontab
cat << EOF >> /etc/crontab
15 * * * * sh sh /home/ubuntu/scripts/stop-check.sh >/dev/null 2>&1
15 * * * * sh sh /home/ubuntu/scripts/backup-world.sh >/dev/null 2>&1
1 * * * * sh sh /home/ubuntu/scripts/playertime.py >/dev/null 2>&1
@reboot sh /home/ubuntu/scripts/alert.sh
EOF