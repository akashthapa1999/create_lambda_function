# ✅ Create an S3 bucket to store the Lambda deployment package
resource "aws_s3_bucket" "s3_bucket_create" {
  bucket = "akas-thapa-lambda-terraform-2025"
}

# ✅ Upload the Lambda ZIP file to the S3 bucket
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.s3_bucket_create.id
  key    = "lambda_function.zip"
  source = "${path.module}/lambda_function.zip"
}

# ✅ Create the Lambda function using the uploaded ZIP file from the S3 bucket
resource "aws_lambda_function" "aws_lambda_using_terraform" {
  function_name = "aws_lambda_using_terraform"
  s3_bucket     = aws_s3_bucket.s3_bucket_create.bucket
  s3_key        = aws_s3_object.lambda_zip.key
  handler       = "lambda_function.lambda_handler"  # Format: filename.function_name
  runtime       = "python3.12"

  # ✅ IAM Role for Lambda execution (pre-existing role in your AWS account)
  role = "arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
}

# ✅ Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_using_terraform.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket_create.arn
}

# ✅ Set up S3 event notification to trigger the Lambda function when new objects are created
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.s3_bucket_create.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_using_terraform.arn
    events              = ["s3:ObjectCreated:*"]  # Trigger on all object creation events
  }

  depends_on = [aws_lambda_permission.allow_s3]  # Ensure permission exists before notification is created
}
