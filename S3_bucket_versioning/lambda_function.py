import boto3

s3 = boto3.client('s3')

s3.download_file(
    Bucket='your-bucket-name',
    Key='report.csv',
    Filename='report_v2.csv',
    ExtraArgs={'VersionId': 'VERSION_ID_FOR_V2'}
)
