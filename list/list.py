import json
import boto3
import os


def list_instances_by_tag(tagkey):
    # When passed a tag key, tag value this will return a list of InstanceIds that were found.

    ec2client = boto3.client('ec2')

    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag-key',
                'Values': [tagkey]
            }
        ]
    )
    server_list = []
    for reservation in (response["Reservations"]):
        for instance in reservation["Instances"]:
            server_list.append(parse_instance_metadata(instance))

    return server_list

def parse_instance_metadata(instance):

    info = {}
    for tag in instance['Tags']:
        info[tag['Key'].lower()] = tag['Value']

    if instance.get('PublicIpAddress'):
        info['ip'] = instance['PublicIpAddress']

    info["InstanceId"] = instance["InstanceId"]
    info['state'] = instance['State']['Name']

    return info

def handler(event, context):
  
    try:
        servers = list_instances_by_tag("Minecraft")
        return {
        'statusCode': 200,
        "headers": {
                "Content-Type": "application/json",
                'Access-Control-Allow-Origin': '*'
            },
        'body': json.dumps(servers)
      }

    except Exception as e:
        return {
          "statusCode": 500,
          "body": json.dumps(str(e))
        }