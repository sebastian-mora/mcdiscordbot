import json
import boto3
from decimal import Decimal as D

from functions.shared import Response

dynamodb = boto3.resource('dynamodb', region_name='us-west-2')
table = dynamodb.Table('mcdata')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, D):
            return float(obj)
        return json.JSONEncoder.default(self, obj)

def getAllPlayers():
  response = table.scan()
  players = response['Items']

  return players

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

def handler(event, context):
  
  try:
      player_data = getAllPlayers()
      return Response.OK200(json.dumps(player_data, cls=DecimalEncoder)).json()

  except Exception as e:
      return Response.InternalServerError500(str(e))