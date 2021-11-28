#!/bin/bash
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
EC2_NAME=$(aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
MESSAGE="IP: ${IP} .... ${EC2_NAME} started! Note the minecraft server might take a few extra moments."
SNS_TOPIC=$(aws --region=us-west-2 ssm get-parameter --name 'alert-sns' --query 'Value')
aws sns publish --region us-west-2 --topic-arn "${SNS_TOPIC}" --message "${MESSAGE}"
#echo "${EC2_NAME} ${IP}"
