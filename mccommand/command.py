import json
import boto3
from mcrcon import MCRcon
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
            server_list.append(instance)

    return server_list

def findServerIp(server_name):
  servers = list_instances_by_tag("Minecraft")
  ip = ""
  for server in servers:

    for tag in server['Tags']:

      if tag['Key'] == 'Name' and tag['Value'] == server_name:
        ip = server['PublicIpAddress']
        
  return ip

def runCommand(ip, cmd):
  password = os.environ['rconpass']
  with MCRcon(ip, password) as mcr:
    resp = mcr.command(cmd)
    return resp
  return "failed to connect to server"


def handler(event, context):
  
  try:
      body = json.loads(event['body'])
      cmd = body['cmd']
      server_name = body['servername']

      # cmd = '/list'
      # server_name = 'modded'
      
      ip = findServerIp(server_name)

      if ip:
        res = runCommand(ip, cmd)
        return {
          'statusCode': 200,
          "headers": {
                  "Content-Type": "application/json",
                  'Access-Control-Allow-Origin': '*'
              },
          'body': json.dumps(res)
        }

      else:
        return {
          'statusCode': 200,
          "headers": {
                  "Content-Type": "application/json",
                  'Access-Control-Allow-Origin': '*'
              },
          'body': json.dumps("Server not found")
        }


  except Exception as e:
      return {
        "statusCode": 500,
        "body": json.dumps(str(e))
      }

print(handler("", ""))