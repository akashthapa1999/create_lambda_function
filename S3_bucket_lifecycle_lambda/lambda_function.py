import boto3
import datetime

s3 = boto3.client('s3')

BUCKET_NAME = "s3-bucket-lifecycle-using-lambda-akash-2025"
DELETE_AFTER_DAYS = 2

def lambda_handler(event, context):
    now = datetime.datetime.utcnow()
    cutoff = now - datetime.timedelta(days=DELETE_AFTER_DAYS)

    response = s3.list_objects_v2(Bucket=BUCKET_NAME)
    if "Contents" not in response:
        return {"status": "no files found"}

    for obj in response["Contents"]:
        key = obj["Key"]
        last_modified = obj["LastModified"].replace(tzinfo=None)

        if last_modified < cutoff:
            print(f"Deleting: {key}")
            s3.delete_object(Bucket=BUCKET_NAME, Key=key)

    return {"status": "done"}
