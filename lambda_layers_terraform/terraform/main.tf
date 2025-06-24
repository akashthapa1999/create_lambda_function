provider "aws" {
  region = "ap-south-1"  # Change as per your region
}

resource "aws_s3_bucket" "lambda_layers_bucket" {
  bucket = var.s3_bucket_name
}


# Upload Layer 1 zip to S3
resource "aws_s3_object" "layer1_zip" {
  bucket = aws_s3_bucket.lambda_layers_bucket.bucket
  key    = "layers/layer1.zip"
  source = "${path.module}/../layers/layer1.zip"
}


# Upload Layer 2 zip to S3
resource "aws_s3_object" "layer2_zip" {
  bucket = aws_s3_bucket.lambda_layers_bucket.bucket
  key    = "layers/layer2-v3.zip"
  source = "${path.module}/../layers/numpy-layer.zip"
}

#Upload lambda zip function
resource "aws_s3_object" "lambda_function_zip" {
    bucket = aws_s3_bucket.lambda_layers_bucket.bucket
    key = "lambda_function.zip"
    source = "${path.module}/../layers/lambda_function.zip"
  
}


# Deploy Layers (Terraform)
resource "aws_lambda_layer_version" "layers1" {
    layer_name = "requests-layer"
    s3_bucket = aws_s3_bucket.lambda_layers_bucket.bucket
    s3_key = aws_s3_object.layer1_zip.key
    compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_layer_version" "layers2" {
    layer_name = "numpy-layers"
    s3_bucket = aws_s3_bucket.lambda_layers_bucket.bucket
    s3_key = aws_s3_object.layer2_zip.key
    compatible_runtimes = ["python3.9"]
  
}

# ✅ Create the Lambda function using the uploaded ZIP file from the S3 bucket
resource "aws_lambda_function" "aws_lambda_using_terraform" {
    function_name = "create_lambda_layers_terraform"
    s3_bucket = aws_s3_bucket.lambda_layers_bucket.bucket
    s3_key = aws_s3_object.lambda_function_zip.key
    handler = "lambda_function.lambda_handler"
    runtime = "python3.9"
    role = "arn:aws:iam::550513526501:role/learning_role"
    layers = [
        aws_lambda_layer_version.layers1.arn,
        aws_lambda_layer_version.layers2.arn
    ]
  
}


