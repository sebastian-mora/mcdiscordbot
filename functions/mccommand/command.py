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
                f"mcrcon -H 127.0.0.1 -p {rconpass} list "
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
      cmd = body['cmd']
      server_name = body['servername']

      instances = list_instances_by_tag_value("Name", server_name)
      if len(instances) > 0:
        res = runCommand(instances[0], cmd)
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
