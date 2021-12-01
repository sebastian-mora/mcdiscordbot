#!/bin/bash
PLAYERCOUNT=$(/usr/local/bin/mcrcon -H 127.0.0.1 -P 25575 -p test "list" | cut -d ' ' -f 3)
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
echo "Player count: $PLAYERCOUNT"
SNS_TOPIC=$(/usr/local/bin/aws ssm get-parameter --name "/mc/alert-sns" --with-decryption --region us-west-2  | jq -r '.Parameter.Value')

if [ "$PLAYERCOUNT" -eq "0" ]; then

	sudo systemctl stop minecraft.service
	/usr/local/bin/aws sns publish --region us-west-2 --topic-arn "${SNS_TOPIC}" --message "Shutting down ${EC2_NAME} due to inactivity."
	sudo shutdown -h now
	echo "Shutting down ${EC2_NAME} due to inactivity."
else
	echo "No shuttoff ${EC2_NAME}"
fi
