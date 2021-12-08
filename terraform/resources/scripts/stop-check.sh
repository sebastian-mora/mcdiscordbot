#!/bin/bash
PLAYERCOUNT=$(/usr/local/bin/mcrcon -H 127.0.0.1 -P 25575 -p test "list" | cut -d ' ' -f 3)
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
SNS_TOPIC=$(/usr/local/bin/aws ssm get-parameter --name "/mc/alert-sns" --with-decryption --region ${AZ::-1}  | jq -r '.Parameter.Value')
AZ=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)

echo "Player count: $PLAYERCOUNT"
if [ "$PLAYERCOUNT" -eq "0" ]; then
	
	# Run save and backup
	/home/ubuntu/scripts/backup-world.sh
	/usr/local/bin/mcrcon -p test "say Stoping the server...." stop

	/usr/local/bin/aws sns publish --region $AZ --topic-arn "${SNS_TOPIC}" --message "Shutting down ${EC2_NAME} due to inactivity."

	sudo shutdown -h now
	echo "Shutting down ${EC2_NAME} due to inactivity."
else
	echo "No shuttoff ${EC2_NAME}"
fi
