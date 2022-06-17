import json
import boto3
from decimal import Decimal
import time
import os
import re

from functions.shared.McRcon import McRcon
from functions.shared import Response


dynamodb = boto3.resource('dynamodb', region_name='us-west-2')
table = dynamodb.Table('mcdata')
# rconpass = os.environ['rconpass']


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return json.JSONEncoder.default(self, obj)


def getPlayer(username):
    response = table.get_item(Key={
        'username': username
    })

    # Cast dec to int
    if response.get('Item'):
        player = response['Item']
        return player

    else:
        return False


def list_running_instances_by_tag(tagkey):
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
            if instance['State']['Name'] == 'running':
                server_list.append(
                    (instance["InstanceId"], instance["InstanceType"]))

    return server_list


def get_active_players(instance_id):
    mcrcon = McRcon('test')
   
    users = mcrcon.runCommand(instance_id, "\"list\" | cut -d \":\" -f 2 | sed 's/ //g'" ).split(",")
    users = [re.sub('\x1b[^m]*m\n', '', user) for user in users]

    return users


def create_player(username):
    player = {
        "username": username,
        "minutes": 0,
        "cost": Decimal(0.0)
    }
    table.put_item(Item=player)
    print(f"Creating new player: {username}")


def update_player_cost(username, individual_cost):
    response = table.get_item(Key={
        'username': username
    })

    if response.get('Item'):
        player = response['Item']
        player['minutes'] = int(player['minutes'] + 1)
        print(player['minutes'])
        player['cost'] = round(player['cost'] + Decimal(individual_cost), 4)
        table.put_item(Item=player)
        print("Updated player time")

    else:
        create_player(username)


def handler(event, context):

    try:
        running_servers = list_running_instances_by_tag("Minecraft")
        for (instance_id, instance_type) in running_servers:
            players = get_active_players(instance_id)
            for username in players:
                cost = .11
                if instance_type == 'm5.xlarge':
                    cost = .21

                update_player_cost(username,  ((cost / (len(players))) / 60))
                print(cost, username)

        return Response.OK200().json()

    except Exception as e:
        return Response.InternalServerError500(str(e))
