import json
import boto3
from datetime import date
import calendar

from functions.shared import Response

def get_month_day_range(date):
    first_day = date.replace(day = 1)
    last_day = date.replace(day = calendar.monthrange(date.year, date.month)[1])
    return first_day, last_day

def handler(event, context):
    billing_client = boto3.client('ce')

    # getting dates (yyyy-MM-dd) and converting to string 
    today = date.today() 
    
    yesterday, today = get_month_day_range(today)
    
    # connecting to cost explorer to get daily aws usage 
    response = billing_client.get_cost_and_usage( 
       TimePeriod={ 
         'Start': str(yesterday), 
         'End': str(today) }, 
       Granularity='MONTHLY', 
       Metrics=[ 'UnblendedCost',] 
    )
    
    
    # iteract through the response to get the daily amount
    for r in response['ResultsByTime']:
        str_amount=(r['Total']['UnblendedCost']['Amount'])
    
    #convert the amount to float
    amount = float(str_amount)
    
    sns = boto3.client('sns')
    
    
    response = sns.publish(
       TopicArn='arn:aws:sns:us-west-2:621056530958:minecraft-alert',
       Message=f'Total montly cost: {amount} '
     )
    return Response.OK200(amount).json()
