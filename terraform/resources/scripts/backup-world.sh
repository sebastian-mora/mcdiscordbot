#!/bin/bash

get_param() {
    P=$(aws ssm get-parameter --with-decryption --name  "$1" | jq -r '.Parameter.Value')
    echo "$P"
}

BUCKET=$(get_param "/mc/backup-bucket")
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
EC2_NAME=$(aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

#! /bin/bash
filename=mc.$EC2_NAME.zip

zip -r /home/ubuntu/server/$filename /home/ubuntu/server/world
aws s3 mv /home/ubuntu/server/$filename s3://$BUCKET/worlds
rm /home/ubuntu/server/$filename