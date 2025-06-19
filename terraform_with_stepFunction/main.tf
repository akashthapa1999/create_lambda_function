# ✅ Create multiple S3 buckets from the provided list of bucket names
resource "aws_s3_bucket" "multiple_buckets" {
  for_each = toset(var.bucket_names)
  bucket   = each.value
}

# ✅ Create an SQS queue to be used as an event source for a Lambda function
resource "aws_sqs_queue" "my_queue" {
  name = "my-lambda-trigger-queue"
}

# ✅ Upload all Lambda zip files to the specified S3 bucket
resource "aws_s3_object" "lambda_zips" {
  for_each = toset([
    "lambda_function.zip",
    "sql_lambda_unction.zip",    # Typo in filename? Should be sql_lambda_function.zip ?
    "updeted_bucket.zip",        # Typo? Should be updated_bucket.zip ?
  ])

  bucket = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].bucket
  key    = each.value
  source = "${path.module}/${each.value}"
  etag   = filemd5("${path.module}/${each.value}")
}

# ✅ Upload the Step Function definition JSON file to S3
resource "aws_s3_object" "json_file" {
  bucket = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].bucket
  key    = "step_function.json"
  source = "${path.module}/step_function.json"
}

# ✅ Create the first Lambda function (used in Step Function or for S3 triggers)
resource "aws_lambda_function" "step_function" {
  function_name = "stepfunction_execute_lambda"
  s3_bucket     = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].bucket
  s3_key        = aws_s3_object.lambda_zips["lambda_function.zip"].key
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = "arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
}

# ✅ Lambda function triggered by SQS (function file = sql_lambda_unction.zip)
resource "aws_lambda_function" "sqs_function" {
  function_name = "sqs_lambda"
  s3_bucket     = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].bucket
  s3_key        = aws_s3_object.lambda_zips["sql_lambda_unction.zip"].key
  handler       = "sql_lambda_unction.lambda_handler"
  runtime       = "python3.12"
  role          = "arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
}

# ✅ Lambda function for handling updates in the S3 bucket
resource "aws_lambda_function" "update_new_bucket" {
  function_name = "updated_bucket_lambda"
  s3_bucket     = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].bucket
  s3_key        = aws_s3_object.lambda_zips["updeted_bucket.zip"].key
  handler       = "updeted_bucket.lambda_handler"
  runtime       = "python3.12"
  role          = "arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
}

# ✅ Allow the S3 bucket to invoke the Lambda function (required for S3 → Lambda triggers)
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.step_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].arn
}

# ✅ Configure S3 bucket notification to trigger the Lambda when an object is created in the bucket
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.multiple_buckets["akash-thapa-lambda-store-2025"].id

  lambda_function {
    lambda_function_arn = aws_lambda_function.step_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# ✅ Define the Step Function and use the JSON definition file from local directory
resource "aws_sfn_state_machine" "lambda_flow" {
  name       = "lambda-conditional-stepfunction"
  role_arn   = "arn:aws:iam::550513526501:role/stepfunction_lambda"
  definition = file("${path.module}/step_function.json")
}

# ✅ Connect the SQS queue to the Lambda function (trigger Lambda whenever messages arrive in the queue)
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.my_queue.arn
  function_name    = aws_lambda_function.step_function.function_name
  batch_size       = 5
  enabled          = true
}
