provider "aws" {
  region = "ap-south-1"
}


resource "aws_s3_bucket" "create_bucket" {
    bucket = "s3-permission-read-only-akash-2025"
}


resource "aws_iam_policy" "lambda_s3_read_only" {
  name        = "LambdaS3ReadOnlyPolicy"
  description = "Read-only access to S3 for Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
        "s3:ListBucket",
        "s3:GetObject"
        
        ],
        Resource = [
            aws_s3_bucket.create_bucket.arn,
            "${aws_s3_bucket.create_bucket.arn}/*"


        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_read_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_read_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_read_only.arn
}

resource "aws_lambda_function" "lambda_reader" {
  filename         = "lambda_function.zip"
  function_name    = "lambda_layers_terraform-akash-2025"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
    source_code_hash = filebase64sha256("lambda_function.zip")
     depends_on = [aws_iam_role_policy_attachment.attach_read_policy]
    
}
