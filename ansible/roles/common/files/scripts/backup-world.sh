#!/bin/bash

AZ=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)

get_param() {
    P=$(/usr/local/bin/aws ssm get-parameter --with-decryption --name  "$1" | jq -r '.Parameter.Value')
    echo "$P"
}

BUCKET=$(get_param "/mc/backup-bucket")
RCONPASS=$(get_param "/mc/rconpass")
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region $AZ --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

# Save MC World
/usr/local/bin/mcrcon -p "$RCONPASS" "say Saving world...." save-all
filename=mc.$EC2_NAME.zip

(cd /home/ubuntu/server && zip  -q -r - world/) > $filename
/usr/local/bin/aws s3 mv $filename s3://$BUCKET/worlds/

/usr/local/bin/mcrcon -p "$RCONPASS" "say Backup saved to S3 bucket"