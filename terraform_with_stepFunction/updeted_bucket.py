import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

def lambda_handler(event, context):
    logger.info("File uploaded event received.")
    print("Event data ----->", event)

    try:
        # 👇 Extract the real S3 event payload
        s3_event = event.get("event", {})  # ✅ Extract the actual S3 event dictionary

        key = s3_event['Records'][0]['s3']['object']['key']
        source_bucket = s3_event['Records'][0]['s3']['bucket']['name']
        destination_bucket = "akash-thapa-s3-image-store-2025"  # ✅ Hardcoded destination bucket

        logger.info(f"Moving '{key}' from '{source_bucket}' to '{destination_bucket}'")

        # ✅ Step 1: Copy the object to destination bucket
        copy_source = {'Bucket': source_bucket, 'Key': key}
        s3.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=key)
        logger.info("✅ File copied successfully.")

        return {
            "statusCode": 200,
            "body": f"✅ File '{key}' copied from '{source_bucket}' to '{destination_bucket}'"
        }

    except Exception as e:
        logger.error("❌ Error during file transfer:")
        logger.error(str(e))
        return {
            "statusCode": 500,
            "body": str(e)
        }
