import os
import re
import boto3


def update_player_time(username):
  response = table.get_item(Key={
  'username': username
  })

  if response.get('Item'):
    player = response['Item']
    player['minutes'] = int(player['minutes']) + increment
    table.put_item(Item=player)
    print("Updated player time")
  
  else:
    create_player(username)

def create_player(username):
  player = {
    "username": username,
    "minutes": 1
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
increment = 1


for username in users:
  update_player_time(username)
