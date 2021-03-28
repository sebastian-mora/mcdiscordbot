import json
import boto3
import os
import requests 

region = os.environ['region']

snsArn = os.environ['snsArn']
api = os.environ['api']

ec2 = boto3.client('ec2', region_name=region)
sns = boto3.client('sns', region_name=region)


def handler(event, context):
    
    try:
    
        response = requests.get(api).text
        response = json.loads(response)

        for server in response:
            
            if server['online'] == True and server['playerCount'] == 0:
                ec2.stop_instances(InstanceIds=[server['InstanceId']])
                sns.publish(
                    TargetArn=snsArn,
                    Message=json.dumps({'default': json.dumps(f"Shuting server {server['name']} down due to inactivity.")}),
                    MessageStructure='json'
                )
        

    except Exception as e:
        raise e
