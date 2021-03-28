import json
import boto3
import os
from mcstatus import MinecraftServer
import socket

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

def parse_mc_server_status(name, ip, InstanceId, status):

  return {
    'ip': ip,
    'InstanceId': InstanceId,
    'name': name,
    'online': True,
    'description': str(status.description['text']), 
    'version': status.version.name,
    'latency': status.latency,
    'playerCount': status.players.online
  }

def parse_instance_metadata(instance):

    info = {}
    for tag in instance['Tags']:
        info[tag['Key'].lower()] = tag['Value']

    if instance.get('PublicIpAddress'):
        info['ip'] = instance['PublicIpAddress']

    info["InstanceId"] = instance["InstanceId"]
    info['state'] = instance['State']['Name']

def handler(event, context):
    
    server_list = []

    for server_ec2 in list_instances_by_tag('Minecraft'):

        try:

            if server_ec2.get('ip'):
                
                ip = server_ec2['ip']
                server = MinecraftServer.lookup(ip)
                status = server.status()
                name = server_ec2['Name']
                server_data = parse_mc_server_status(name, ip, server_ec2['InstanceId'], status)
                server_list.append(server_data)

        except ConnectionRefusedError:
            pass
        except (socket.timeout, socket.gaierror):
            pass
        except Exception as e:
            print(e)

    return {
            'statusCode': 200,
            "headers": {
                    "Content-Type": "application/json",
                    'Access-Control-Allow-Origin': '*'
                },
            'body': json.dumps(server_list)
        } 

