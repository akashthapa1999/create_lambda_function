import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('stepfunctions')
    print("Event of data is S3---->",event)
    if "Records" in event:
        record = event["Records"][0]

        if record["eventSource"] in "aws:sqs":
            source = "sqs"
        elif record["eventSource"] in "aws:s3":
            source = "s3"
        else:
            source = "unknown"
    else:
        source = "unknown"

    print("Detected event source:", source)

    response = client.start_execution(
        stateMachineArn='arn:aws:states:ap-south-1:550513526501:stateMachine:lambda-conditional-stepfunction',
        input=json.dumps({
            "source": source,
            "event": event
        })
    )

    return {
        "statusCode": 200,
        "body": f"Step Function Triggered with source: {source}"
    }




