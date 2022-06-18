import requests
import os


hook = os.environ['webhook']

def handler(event, context):

    message = event['Records'][0]['Sns']['Message']

    data = {
        "content" : "",
        "username" : "Minecraft Bot Alert"
    }

    #leave this out if you dont want an embed
    #for all params, see https://discordapp.com/developers/docs/resources/channel#embed-object
    data["embeds"] = [
        {
            "title" : "Alert",
            "description": str(message)
        }
    ]

    result = requests.post(hook, json = data)

    try:
        result.raise_for_status()
    except requests.exceptions.HTTPError as err:
        print(err)
    else:
        print("Payload delivered successfully, code {}.".format(result.status_code))
