import json
import boto3
import os 

region = os.environ['region']

ec2 = boto3.client('ec2', region_name=region)


def list_instances_by_tag_value(tagkey, tagvalue):

    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:'+tagkey,
                'Values': [tagvalue]
            }
        ]
    )
    instancelist = []
    for reservation in (response["Reservations"]):
        for instance in reservation["Instances"]:
            instancelist.append(instance["InstanceId"])
    return instancelist

def handler(event, context):

    try:
        body = json.loads(event['body'])
        action = body['action']
        name = body['name']

        # This could be used to delete any ec2
        instances = list_instances_by_tag_value("Name", name)

        if(len(instances) <= 0):
            return {
                "statusCode": 200,
                "body": f"No servers found with name {name}"
            }
    except Exception as e:
        return {
            "statusCode": 403,
            "body":str(e)
        }

    if action == 'start':
        ec2.start_instances(InstanceIds=instances)
        return {
            "statusCode": 200,
            "body": 'Starting server'
        }
    elif action == 'stop':
        ec2.stop_instances(InstanceIds=instances)
        return {
            "statusCode": 200,
            "body": 'Stopping server'
        }
    else:
        return {
            "statusCode": 403,
            "body": 'Unknown action.'
        }