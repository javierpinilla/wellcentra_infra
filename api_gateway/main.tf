data "aws_caller_identity" "current" {}

# VPC existente
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

# SG Existente para EC2/Lambda
data "aws_security_group" "ec2_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-ec2-lambda-sg"]
  }
}

# Subredes privadas para ubicar EC2
data "aws_subnet" "private_subnets" {
  count = 3
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-private-subnet-${count.index + 1}"]
  }
}

# Lambda en Go
resource "aws_lambda_function" "go_api" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main"
  runtime       = "go1.x"
  memory_size   = 128
  timeout       = 30

  # Código inline para Lambda en Go
  code {
    zip_file = <<EOT
package main

import (
    "github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
    Message string `json:"message"`
}

func handler() (Response, error) {
    return Response{Message: "¡Hola Mundo!"}, nil
}

func main() {
    lambda.Start(handler)
}
EOT
  }

  environment {
    variables = {
      DB_SECRET = local.secret_name
    }
  }

  vpc_config {
    subnet_ids         = element(data.aws_subnet.private_subnets, 1).id
    security_group_ids = [data.aws_security_group.ec2_sg.id]
  }

  tags = merge(var.common_tags, {
    Name = local.lambda_name
  })
}

# IAM Role para Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${local.lambda_name}-lambda-exec-role"

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

# Police lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Police vpc access
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = local.lambda_name
  protocol_type = "HTTP"
  description   = "API Gateway for Go Lambda function"

  tags = var.common_tags
}

#Lambda Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.go_api.invoke_arn
}

# Ruta API
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  tags = var.common_tags
}

# Permisos API Gateway invoque Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.go_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Police para secret y network
resource "aws_iam_policy" "lambda_additional_permissions" {
  name        = "${local.vpc_name}-lambda-additional-permissions"
  description = "Permisos adicionales para Lambda: Secrets Manager, Logs y eni"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${local.secret_name}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_additional_perms" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_additional_permissions.arn
}