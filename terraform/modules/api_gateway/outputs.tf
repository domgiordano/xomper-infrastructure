output "api_gateway_resource_id" {
  value       = local.resource_id
  description = "API Gateway Resource ID"
}

output "http_method" {
  value       = aws_api_gateway_method.api_gateway_method.http_method
  description = "HTTP METHOD for API Gateway Method Resource"
}

output "path_part" {
  value       = var.path_part
  description = "Path Part for API Gateway Resource"
}