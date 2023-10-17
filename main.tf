# Create an S3 bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.bucket_name # Change this to a unique bucket name
}

# Define Lambda functions
resource "aws_lambda_function" "lambda_function" {
  count         = var.nooflambdas
  function_name = "my-lambda-function-${count.index + 1}"
  description   = "lambda function"
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "nodejs14.x"
  handler       = "lambda_handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "lambda_function_${count.index + 1}.zip"  # Use the specific Lambda ZIP file names
  source_code_hash = data.archive_file.lambda_code[count.index].output_base64sha256

  depends_on = [aws_s3_object.lambda_code]
}

# Upload Lambda ZIP files to S3
resource "aws_s3_object" "lambda_code" {
  count  = var.nooflambdas
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function_${count.index + 1}.zip"
  source = "lambda_function_${count.index + 1}.zip" # Update to the actual path
}

# Define IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"
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

# Attach the AWS Lambda Basic Execution Policy to the IAM roles
resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  count      = var.nooflambdas
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution_role.name]
  name       = "lambda-policy-attachment-${count.index}"
}

# Calculate the source code hash for each Lambda ZIP file
data "archive_file" "lambda_code" {
  count       = var.nooflambdas
  type        = "zip"
  source_file = "lambda_function_${count.index + 1}.js"
  output_path = "lambda_function_${count.index + 1}.zip"
}
