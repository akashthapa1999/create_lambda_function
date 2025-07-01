import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = "s3-permission-read-only-akash-2025"  # Update this if needed
    prefix = ""

    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    return {
        "statusCode": 200,
        "body": [obj["Key"] for obj in response.get("Contents", [])]
    }
