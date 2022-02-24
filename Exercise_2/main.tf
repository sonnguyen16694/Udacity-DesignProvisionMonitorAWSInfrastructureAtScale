
provider "aws" {
  profile = var.aws_creadentials
  region = var.aws_region
}
#Define IAM role for lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Define CloudWatch for Lambda function

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14
}

#Define IMA policy for Lambda function write logs to cloud watch
resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "lambda_logs_policy"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


#Assign policy to the role
resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
}


#Define AWS Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  filename = var.lambda_source_path
  source_code_hash = filebase64sha256(var.lambda_source_path)
  handler = "lambda.lambda_handler"
  runtime = "python3.8"
  role = aws_iam_role.iam_for_lambda.arn
  environment{
      variables = {
          greeting = "Hello Udacity!"
      }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logs_policy, aws_cloudwatch_log_group.lambda_log_group]
}