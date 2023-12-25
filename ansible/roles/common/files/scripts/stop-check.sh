#!/bin/bash

get_param() {
    P=$(/usr/local/bin/aws ssm get-parameter --with-decryption --name "$1" | jq -r '.Parameter.Value')
    echo "$P"
}

RCONPASS=$(get_param "/mc/rconpass")
AZ=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)

# Call world_time.sh and capture its output
WORLD_TIME_OUTPUT=$(/home/ubuntu/scripts/world_time.sh)

PLAYERCOUNT=$(/usr/local/bin/mcrcon -H 127.0.0.1 -P 25575 -p "$RCONPASS" "list" | grep -oP 'There are \K\d+' || echo "Error getting player count")

AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region "$AZ" --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
SNS_TOPIC=$(get_param "/mc/alert-sns")

echo "Player count: $PLAYERCOUNT"
echo "World Time Output: $WORLD_TIME_OUTPUT"

if [ "$PLAYERCOUNT" -eq "0" ]; then
    # Run save and backup
    /home/ubuntu/scripts/backup-world.sh
    /usr/local/bin/mcrcon -p "$RCONPASS" "say Stopping the server...." stop

    if [ $? -eq 0 ]; then
        sleep 5  # Add a 5-second delay
        SHUTDOWN_MESSAGE="Shutting down ${EC2_NAME} due to inactivity. $WORLD_TIME_OUTPUT"
        /usr/local/bin/aws sns publish --region "$AZ" --topic-arn "${SNS_TOPIC}" --message "$SHUTDOWN_MESSAGE"
        sudo shutdown -h now
        echo "$SHUTDOWN_MESSAGE"
    else
        echo "Error stopping the server."
    fi
else
    echo "No shutdown ${EC2_NAME}"
fi
