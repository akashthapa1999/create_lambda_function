import json

def lambda_handler(event, context):
    print("Event is --------->",event)
    data  = event['event']['Records'][0]["body"]
    print("Data of pring is ------->", data)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
