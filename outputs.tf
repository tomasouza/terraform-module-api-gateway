# Outputs for API Gateway module

output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.owners_api.id
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.owners_api.arn
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.owners_api.execution_arn
}

output "api_name" {
  description = "Name of the API Gateway"
  value       = aws_api_gateway_rest_api.owners_api.name
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.stage_name
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.arn
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.id
}

output "root_resource_id" {
  description = "Root resource ID of the API Gateway"
  value       = aws_api_gateway_rest_api.owners_api.root_resource_id
}

output "owners_resource_id" {
  description = "Resource ID for /owners"
  value       = aws_api_gateway_resource.owners.id
}

output "owners_id_resource_id" {
  description = "Resource ID for /owners/{emailHash}"
  value       = aws_api_gateway_resource.owners_id.id
}

output "owners_validate_resource_id" {
  description = "Resource ID for /owners/{emailHash}/validate-invoice"
  value       = aws_api_gateway_resource.owners_validate.id
}

output "usage_plan_id" {
  description = "ID of the usage plan (if created)"
  value       = var.create_usage_plan ? aws_api_gateway_usage_plan.usage_plan[0].id : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group (if access logging is enabled)"
  value       = var.enable_access_logging ? aws_cloudwatch_log_group.api_gateway_logs[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group (if access logging is enabled)"
  value       = var.enable_access_logging ? aws_cloudwatch_log_group.api_gateway_logs[0].arn : null
}