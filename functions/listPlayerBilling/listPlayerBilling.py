import json
import boto3
from decimal import Decimal as D

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
      return {
      'statusCode': 200,
      "headers": {
              "Content-Type": "application/json",
              'Access-Control-Allow-Origin': '*'
          },
      'body': json.dumps(player_data, cls=DecimalEncoder)
    }

  except Exception as e:
      return {
        "statusCode": 500,
        "body": json.dumps(str(e))
      }
print(handler(1,1))