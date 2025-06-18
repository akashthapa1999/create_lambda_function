# import boto3
# import os
# import logging

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# s3 = boto3.client('s3')

# def lambda_handler(event, context):
#     logger.info("File uploaded event received.")
#     print("Event data ----->", event)

#     try:
#         key = event['Records'][0]['s3']['object']['key']
#         source_bucket = event['Records'][0]['s3']['bucket']['name']
#         destination_bucket = os.environ['BOOKSTORE_FINAL_BUCKET']

#         logger.info(f"Moving '{key}' from '{source_bucket}' to '{destination_bucket}'")

#         # Step 1: Copy the object
#         copy_source = {'Bucket': source_bucket, 'Key': key}
#         s3.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=key)
#         logger.info(" File copied successfully.")

#         # # Step 2: Delete the original
#         # s3.delete_object(Bucket=source_bucket, Key=key)
#         # logger.info(" Original file deleted from source bucket.")

#     except Exception as e:
#         logger.error(" Error during file transfer:")
#         logger.error(str(e))


import json


def lambda_handler(event, context):
    print("Full Event:", json.dumps(event))  # Print entire event as JSON
    for i in event:
        print(f"Key: {i}, Value: {event[i]}")
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }





#Event of lambda


# {
#   "Records": [
#     {
#       "eventVersion": "2.1",
#       "eventSource": "aws:s3",
#       "awsRegion": "us-east-1",
#       "eventTime": "2025-05-17T12:00:00.000Z",
#       "eventName": "ObjectCreated:Put",
#       "s3": {
#         "bucket": {
#           "name": "book-store-app-fastapi"
#         },
#         "object": {
#           "key": "images/patrick-tomasso-Oaqk7qqNh_c-unsplash.jpg"
#         }
#       }
#     }
#   ]
# }

