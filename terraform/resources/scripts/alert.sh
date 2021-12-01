#!/bin/bash
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
MESSAGE="IP: ${IP} .... ${EC2_NAME} started! Note the minecraft server might take a few extra moments."
SNS_TOPIC=$( /usr/local/bin/aws ssm get-parameter --name "/mc/alert-sns" --with-decryption --region us-west-2  | jq -r '.Parameter.Value')
/usr/local/bin/aws sns publish --region us-west-2 --topic-arn "${SNS_TOPIC}" --message "${MESSAGE}"
#echo "${EC2_NAME} ${IP}"
