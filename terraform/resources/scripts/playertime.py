import os
import re
import boto3
from decimal import Decimal

def update_player(username, individual_cost):
  response = table.get_item(Key={
  'username': username
  })

  if response.get('Item'):
    player = response['Item']
    player['minutes'] = int(player['minutes'] + 1)
    player['cost'] = round(player['cost'] + Decimal(individual_cost), 4)
    table.put_item(Item=player)
    print("Updated player time")
  
  else:
    create_player(username)

def create_player(username):
  player = {
    "username": username,
    "minutes": 0,
    "cost": Decimal(0.0)
  }
  table.put_item(Item=player)
  print(f"Creating new player: {username}")



userCmd = "/home/ubuntu/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p test \"list\" | cut -d \":\" -f 2 | sed 's/ //g'"
users = os.popen(userCmd).read()
users = users.split(",")
# clean up some dumn ascii escape char
users = [re.sub('\x1b[^m]*m\n', '', user) for user in users]

dynamodb = boto3.resource('dynamodb', region_name='us-west-2')
table = dynamodb.Table('minecraft_players')

ec2_cost = .11
individual_cost = (ec2_cost / 60) / len(users)

for username in users:
  if len(username) > 0:
    update_player(username, individual_cost)
