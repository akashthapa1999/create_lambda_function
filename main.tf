# provider "aws" {
#   region = "ap-south-1"
# }

# # IAM Role for Lambda execution
# resource "aws_iam_role" "lambda_exec_role" {
#   name = "terraform_lambda_exec_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action    = "sts:AssumeRole",
#       Effect    = "Allow",
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# # Attach AWS managed policy for Lambda basic execution (CloudWatch logs)
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_exec_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# # Lambda Function using container image
# resource "aws_lambda_function" "terraform_lambda_function" {
#   function_name = "terraform_lambda_function"
#   role          = aws_iam_role.lambda_exec_role.arn

#   package_type  = "Image"
#   image_uri     = "550513526501.dkr.ecr.ap-south-1.amazonaws.com/book_store_lambda_function:latest"  # Replace with your actual ECR image URI

#   timeout       = 3
#   memory_size   = 128

#   environment {
#     variables = {
#       BOOKSTORE_FINAL_BUCKET = "bookstore-final-bucket"
#     }
#   }

#   architectures = ["x86_64"]

#   ephemeral_storage {
#     size = 512
#   }

#   tracing_config {
#     mode = "PassThrough"
#   }
# }



provider "aws" {
  region = "ap-south-1"
}

# resource "aws_lambda_function" "lambda_from_ecr" {
#   function_name = "aws_lambda_using_docker_image"
#   package_type  = "Image"
#   image_uri     = "550513526501.dkr.ecr.ap-south-1.amazonaws.com/aws_practice_lambda_function" # Example: 550513526501.dkr.ecr.ap-south-1.amazonaws.com/aws-practice-lambda:latest
#   role          ="arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
#   timeout       = 30
#   memory_size   = 256
# }

resource "aws_lambda_function" "lambda_from_ecr" {
  function_name = "aws_lambda_using_docker_image"
  package_type  = "Image"
  image_uri     = "550513526501.dkr.ecr.ap-south-1.amazonaws.com/aws_practice_lambda_function:latest"
  role          ="arn:aws:iam::550513526501:role/service-role/book_store_lambda_function-role-i01ci2r0"
}

