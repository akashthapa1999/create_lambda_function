provider "aws" {
  region = "ap-south-1"  # Set your desired AWS region
}

resource "aws_s3_bucket" "s3_bucket_normal" {
  bucket = "s3-bucket-lifecycle-akash-2025"  # Replace with your unique bucket name
}

resource "aws_s3_bucket_lifecycle_configuration" "delete_old_files" {
  bucket = aws_s3_bucket.s3_bucket_normal.id  # Attach lifecycle rule to this bucket

  rule {
    id     = "delete-after-2-days"  # Rule identifier
    status = "Enabled"              # Must be enabled to take effect

    expiration {
      days = 2  # Automatically delete objects after 2 days
    }

    filter {}  # Empty filter applies to ALL objects in the bucket
  }
}








resource "aws_s3_bucket" "s3_bucket_using_lambda" {
  bucket = "s3-bucket-lifecycle-using-lambda-akash-2025"  # Replace with your unique bucket name
}

# ✅ Upload the Lambda ZIP file to the S3 bucket
resource "aws_s3_object" "lambda_bucket" {
  bucket = aws_s3_bucket.s3_bucket_using_lambda.id
  key    = "lambda_function.zip"
  source = "${path.module}/lambda_function.zip"
}



# ✅ Create the Lambda function using the uploaded ZIP file from the S3 bucket
resource "aws_lambda_function" "aws_lambda_using_terraform" {
  function_name = "aws_lambda_using_terraform"
  s3_bucket     = aws_s3_bucket.s3_bucket_using_lambda.bucket
  s3_key        = aws_s3_object.lambda_bucket.key
  handler       = "lambda_function.lambda_handler"  # Format: filename.function_name
  runtime       = "python3.12"

  # ✅ IAM Role for Lambda execution (pre-existing role in your AWS account)
  role = "arn:aws:iam::550513526501:role/learning_role"
}

# EventBridge Rule to trigger Lambda daily
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily-s3-cleanup"
  schedule_expression = "rate(1 day)"  # Runs once per day
}


# Link EventBridge Rule to Lambda Function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "lambda"
  arn       = aws_lambda_function.aws_lambda_using_terraform.arn
}


# Grant EventBridge permission to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_using_terraform.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
