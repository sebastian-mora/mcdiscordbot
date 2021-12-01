import json
import boto3
import os 
import time 

region = os.environ['region']
ec2 = boto3.client('ec2', region_name=region)
rconpass = os.environ['rconpass']


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
            if instance['State']['Name'] in ['stopped', 'running']:
                instancelist.append(instance["InstanceId"])
    return instancelist


def runCommand(instance_id, cmd):
    client = boto3.client('ssm')
    response = client.send_command(
        InstanceIds=[instance_id],
        DocumentName='AWS-RunShellScript',
        Parameters={
            'commands': [
                f"mcrcon -H 127.0.0.1 -p test save-all stop"
            ]
        }
    )
    command_id = response['Command']['CommandId']
    tries = 0
    output = ''
    while tries < 10:
        tries = tries + 1
        try:
            time.sleep(0.5)  # some delay always required...
            result = client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
            )
            print(result)
            if result['Status'] == 'InProgress':
                continue
            output = result['StandardOutputContent']
            break
        except client.exceptions.InvocationDoesNotExist:
            continue

    return output 

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
        try:
            runCommand(instances[0], "")
        except:
            pass
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