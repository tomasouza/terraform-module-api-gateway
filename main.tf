# Terraform module for API Gateway

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "owners_api" {
  name        = "${var.environment}-${var.api_name}"
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  # CORS configuration
  binary_media_types = var.binary_media_types

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.api_name}"
      Environment = var.environment
    }
  )
}

# API Gateway Resource for /owners
resource "aws_api_gateway_resource" "owners" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  parent_id   = aws_api_gateway_rest_api.owners_api.root_resource_id
  path_part   = "owners"
}

# API Gateway Resource for /owners/{emailHash}
resource "aws_api_gateway_resource" "owners_id" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  parent_id   = aws_api_gateway_resource.owners.id
  path_part   = "{emailHash}"
}

# API Gateway Resource for /owners/{emailHash}/validate-invoice
resource "aws_api_gateway_resource" "owners_validate" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  parent_id   = aws_api_gateway_resource.owners_id.id
  path_part   = "validate-invoice"
}

# CORS OPTIONS method for /owners
resource "aws_api_gateway_method" "owners_options" {
  rest_api_id   = aws_api_gateway_rest_api.owners_api.id
  resource_id   = aws_api_gateway_resource.owners.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "owners_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners.id
  http_method = aws_api_gateway_method.owners_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "owners_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners.id
  http_method = aws_api_gateway_method.owners_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "owners_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners.id
  http_method = aws_api_gateway_method.owners_options.http_method
  status_code = aws_api_gateway_method_response.owners_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# CORS OPTIONS method for /owners/{emailHash}
resource "aws_api_gateway_method" "owners_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.owners_api.id
  resource_id   = aws_api_gateway_resource.owners_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "owners_id_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners_id.id
  http_method = aws_api_gateway_method.owners_id_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "owners_id_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners_id.id
  http_method = aws_api_gateway_method.owners_id_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "owners_id_options" {
  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = aws_api_gateway_resource.owners_id.id
  http_method = aws_api_gateway_method.owners_id_options.http_method
  status_code = aws_api_gateway_method_response.owners_id_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda proxy integration for all methods
locals {
  methods = [
    { resource = aws_api_gateway_resource.owners.id, method = "GET" },
    { resource = aws_api_gateway_resource.owners.id, method = "POST" },
    { resource = aws_api_gateway_resource.owners_id.id, method = "GET" },
    { resource = aws_api_gateway_resource.owners_id.id, method = "PUT" },
    { resource = aws_api_gateway_resource.owners_id.id, method = "DELETE" },
    { resource = aws_api_gateway_resource.owners_validate.id, method = "GET" }
  ]
}

# API Gateway Methods
resource "aws_api_gateway_method" "lambda_methods" {
  count = length(local.methods)

  rest_api_id   = aws_api_gateway_rest_api.owners_api.id
  resource_id   = local.methods[count.index].resource
  http_method   = local.methods[count.index].method
  authorization = var.authorization_type

  request_parameters = var.request_parameters
}

# API Gateway Integrations
resource "aws_api_gateway_integration" "lambda_integrations" {
  count = length(local.methods)

  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = local.methods[count.index].resource
  http_method = aws_api_gateway_method.lambda_methods[count.index].http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn
}

# API Gateway Method Responses
resource "aws_api_gateway_method_response" "lambda_responses" {
  count = length(local.methods)

  rest_api_id = aws_api_gateway_rest_api.owners_api.id
  resource_id = local.methods[count.index].resource
  http_method = aws_api_gateway_method.lambda_methods[count.index].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integrations,
    aws_api_gateway_integration.owners_options,
    aws_api_gateway_integration.owners_id_options
  ]

  rest_api_id = aws_api_gateway_rest_api.owners_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.owners.id,
      aws_api_gateway_resource.owners_id.id,
      aws_api_gateway_resource.owners_validate.id,
      aws_api_gateway_method.lambda_methods,
      aws_api_gateway_integration.lambda_integrations,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.owners_api.id
  stage_name    = var.stage_name

  # Access logging
  dynamic "access_log_settings" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway_logs[0].arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
        error          = "$context.error.message"
        errorType      = "$context.error.messageString"
      })
    }
  }

  # X-Ray tracing
  xray_tracing_enabled = var.enable_xray_tracing

  tags = var.tags
}

# CloudWatch Log Group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  count = var.enable_access_logging ? 1 : 0

  name              = "/aws/apigateway/${var.environment}-${var.api_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# API Gateway Account (for CloudWatch logging)
resource "aws_api_gateway_account" "account" {
  count = var.enable_access_logging ? 1 : 0

  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch[0].arn
}

# IAM role for API Gateway CloudWatch logging
resource "aws_iam_role" "api_gateway_cloudwatch" {
  count = var.enable_access_logging ? 1 : 0

  name = "${var.environment}-${var.api_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  count = var.enable_access_logging ? 1 : 0

  role       = aws_iam_role.api_gateway_cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Usage Plan (if API key is required)
resource "aws_api_gateway_usage_plan" "usage_plan" {
  count = var.create_usage_plan ? 1 : 0

  name         = "${var.environment}-${var.api_name}-usage-plan"
  description  = "Usage plan for ${var.environment} ${var.api_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.owners_api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }

  throttle_settings {
    rate_limit  = var.throttle_rate_limit
    burst_limit = var.throttle_burst_limit
  }

  tags = var.tags
}



