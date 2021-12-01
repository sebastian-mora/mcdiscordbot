#!/bin/bash
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
EC2_NAME=$(/usr/local/bin/aws ec2 describe-tags --region us-west-2 --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

DNS=$(/usr/local/bin/aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${AWS_INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_NAME`].Value' --output text)

MESSAGE="IP: ${DNS} (${IP}) .... ${EC2_NAME} started!"

/usr/local/bin/aws sns publish --region us-west-2 --topic-arn "${SNS_TOPIC}" --message "${MESSAGE}"

