#!/bin/bash
apt-get update
apt install -y unzip openjdk-17-jdk wget jq zip git

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Setup vars 
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

# Download server
mkdir /home/ubuntu/server
mkdir /home/ubuntu/scripts
wget -O /home/ubuntu/server/server.jar ${url}
echo "eula=true" > /home/ubuntu/server/eula.txt
chmod +x /home/ubuntu/server/server.jar

# Pull scripts
aws s3 sync s3://${bucket}/ /home/ubuntu/scripts

# Install Rcon
wget -O /home/ubuntu/server/rcon.tar.gz https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-linux-x86-64.tar.gz
tar -xvf /home/ubuntu/server/rcon.tar.gz -C /usr/local/bin

# Check if there is no world file
FILE=/home/ubuntu/server/world
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    aws s3 cp s3://${bucket}/backup/mc.$EC2_NAME.zip /home/ubuntu/server/$filename 
    unzip /home/ubuntu/server/$filename  -d /home/ubuntu/server
fi


# Setup minecraft service
cat << EOF > /etc/systemd/system/minecraft@.service 
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/home/ubuntu/server
Restart=always
ExecStart=/usr/bin/screen -DmS mc-%i /usr/bin/java -Xmx4G -jar /home/ubuntu/server/server.jar nogui
ExecStartPost=/bin/sh -c "/home/ubuntu/scripts/alert.sh"

EOF

systemctl start minecraft@survival
systemctl enable minecraft@survival


# Setup Crontabs
crontab -l > crontab_new 
cat << EOF >> crontab_new 
15 * * * * sh sh /home/ubuntu/scripts/stop-check.sh >/dev/null 2>&1
15 * * * * sh sh /home/ubuntu/scripts/backup-world.sh >/dev/null 2>&1
1 * * * * sh sh /home/ubuntu/scripts/playertime.py >/dev/null 2>&1
EOF
crontab crontab_new
rm crontab_new

# Update owner of folders
chown -R ubuntu /home/ubuntu/server
chown -R ubuntu /home/ubuntu/scripts
chmod -R +x /home/ubuntu/scripts
chmod +x /home/ubuntu/server/rcon