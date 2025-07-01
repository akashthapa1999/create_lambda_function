# provider "aws" {
#     region = "ap-south-1"
# }


# resource "aws_s3_bucket" "lambda_layers_bucket" {
#   bucket = "lambda-versioning-akash-2025"
# }


# # Upload Layer 1 zip to S3
# resource "aws_s3_object" "layer1_zip" {
#   bucket = aws_s3_bucket.lambda_layers_bucket.bucket
#   key    = "lambda_function.zip"
#   source = "${path.module}/lambda_function.zip"

# }



# # ✅ Create the Lambda function using the uploaded ZIP file from the S3 bucket
# resource "aws_lambda_function" "aws_lambda_using_terraform" {
#     function_name = "create_lambda_layers_terraform"
#     s3_bucket = aws_s3_bucket.lambda_layers_bucket.bucket
#     s3_key = aws_s3_object.layer1_zip.key
#     handler = "lambda_function.lambda_handler"
#     runtime = "python3.9"
#     role = "arn:aws:iam::550513526501:role/learning_role"
  
# }



provider "aws" {
  region = "ap-south-1"
}

resource "aws_lambda_function" "example" {
  filename         = "lambda_function.zip"
  function_name    = "lambda-versioning"
  role             = "arn:aws:iam::550513526501:role/learning_role"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_function.zip")
  runtime          = "python3.9"
  publish          = true  # ✅ This publishes a version
}

# Create an alias to refer to the published version
resource "aws_lambda_alias" "example" {
  name             = "prod"
  function_name    = aws_lambda_function.example.function_name
  function_version = aws_lambda_function.example.version  # ✅ Access version from lambda_function
  description      = "Production alias"
}
