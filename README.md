# mcdiscordbot

Allow starting and stopping of Minecraft server instances hosted in AWS via a
Discord bot interface. 

[![Alt text](./diagram.jpg)]

## Deploying Bot

This repo is not a plug-and-play solution, there a few elements which have not yet be configured with Terraform to automate deployment. In the future, I would like to have this process completely automated. 

The first feature is the bot client. This is not included in the repo but only interfaces with the API deployed here. I will leave the implementation of the API client for you. 

The servers need to be configured and deployed with the following tags Name, Description, Minecraft: true.

SNS and cloud watch need to be created as well.

Long story short this is not in a state to be auto deployed, rather use it as a reference on how to implement for now. 

## Usage

**!mc list**

List all available server instances along with their associated metadata like name etc.

**!mc status**

List all running Minecraft servers and returns metadata about game server and player count.

**!mc start {name}**

Start the specified Minecraft server. After a few started an alert will be sent in the chat with the connection information.

**!mc stop {name}**

Stop the specified Minecraft server. 


After a set time (default: 30mins) any running servers with a player account of 0 will be shutoff.

## Features 
* APIGateway
* SNS
* Lambda
* EC2
* CloudWatch
* Cost Analyzer 
* Tag Policies


## EC2 Setup 


### stop-check.sh

```
#!/bin/bash
PLAYERCOUNT=$(/home/ubuntu/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p test "list" | cut -d ' ' -f 3)
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
echo "Player count: $PLAYERCOUNT"

if [ $PLAYERCOUNT == 0 ]; then

	sudo systemctl stop minecraft.service
	aws sns publish --region us-west-2 --topic-arn arn:aws:sns:us-west-2:621056530958:minecraft-alert --message "Shutting down ${EC2_NAME} due to inactivity."
	sudo shutdown -h now
	echo "Shutting down ${EC2_NAME} due to inactivity."
else
	echo "No shuttoff ${EC2_NAME}"
fi
```

### alert.sh 

```
#!/bin/bash
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
EC2_NAME=$(aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
MESSAGE="IP: ${IP} .... ${EC2_NAME} started! Note the minecraft server might take a few extra moments."
aws sns publish --region us-west-2 --topic-arn arn:aws:sns:us-west-2:621056530958:minecraft-alert --message "${MESSAGE}"
#echo "${EC2_NAME} ${IP}"

```

### crontab

```
15 * * * * sh /home/ubuntu/stop-check.sh
@reboot sh /home/ubuntu/alert.sh
```