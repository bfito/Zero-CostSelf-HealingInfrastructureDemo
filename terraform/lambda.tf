# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Basic Lambda execution permissions
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for EC2 operations (Phoenix healing)
resource "aws_iam_policy" "lambda_ec2_policy" {
  name = "${var.project_name}-lambda-ec2-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:TerminateInstances",
          "ec2:RunInstances", 
          "ec2:DescribeInstances",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricAlarm"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

# The Lambda function itself
resource "aws_lambda_function" "phoenix_response" {
  function_name    = "${var.project_name}-response"
  role            = aws_iam_role.lambda_exec_role.arn
  handler         = "phoenix-response.lambda_handler"
  runtime         = "python3.11"
  filename        = "${path.module}/../lambda/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda.zip")
  
  tags = {
    Name    = "${var.project_name}-lambda"
    Purpose = "phoenix-auto-response"
  }
}

# Allow CloudWatch to invoke the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.phoenix_response.function_name
  principal     = "events.amazonaws.com"
}