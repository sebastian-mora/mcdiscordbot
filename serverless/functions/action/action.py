import imp
import json
import boto3
import os 
import time 

from functions.shared import Response
from functions.shared.McRcon import McRcon

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

def handler(event, context):

    try:
        body = json.loads(event['body'])
        action = body['action']
        name = body['name']

        mcrcon = McRcon(password="test")

        # This could be used to delete any ec2
        instances = list_instances_by_tag_value("Name", name)

        if(len(instances) <= 0):
            return Response.OK200(f"No servers found with name {name}").json()
    except Exception as e:
        return Response.BadRequest400(str(e)).json()

    if action == 'start':
        ec2.start_instances(InstanceIds=instances)
        return Response.OK200('Starting server').json()
    elif action == 'stop':
        try:
            mcrcon.runCommand(instances[0], "save-all stop")
            ec2.stop_instances(InstanceIds=instances)
        except:
            Response.InternalServerError500("Failed to save world...server will stay running.")
        
        return Response.OK200('Stopping server').json()
    else:
        return Response.BadRequest400(f"Unknown command: {action}").json()