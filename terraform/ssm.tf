# AWS
resource "aws_ssm_parameter" "access_key"{
    name        = "/${var.app_name}/aws/ACCESS_KEY"
    description = "AWS Access Key"
    type        = "SecureString"
    value       = var.access_key
    tags        = merge(local.standard_tags, tomap({"name" = "${var.app_name}-aws-access-key"}))
}
resource "aws_ssm_parameter" "secret_key"{
    name        = "/${var.app_name}/aws/SECRET_KEY"
    description = "AWS Secret Key"
    type        = "SecureString"
    value       = var.secret_key
    tags        = merge(local.standard_tags, tomap({"name" = "${var.app_name}-aws-secret-key"}))
}

#API
# resource "aws_ssm_parameter" "api_secret_key"{
#     name        = "/${var.app_name}/api/API_SECRET_KEY"
#     description = "Web API Secret Keyt"
#     type        = "SecureString"
#     value       = var.api_secret_key
#     tags        = merge(local.standard_tags, tomap({"name" = "${var.app_name}-api-secret-key"}))
# }
# resource "aws_ssm_parameter" "api_auth_token"{
#     name        = "/${var.app_name}/api/API_AUTH_TOKEN"
#     description = "Web API Auth Token"
#     type        = "SecureString"
#     value       = var.api_access_token
#     tags        = merge(local.standard_tags, tomap({"name" = "${var.app_name}-api-auth-token"}))
# }
# resource "aws_ssm_parameter" "api_id"{
#     name        = "/${var.app_name}/api/API_ID"
#     description = "Web API ID"
#     type        = "SecureString"
#     value       = aws_api_gateway_rest_api.api_gateway.id
#     tags        = merge(local.standard_tags, tomap({"name" = "${var.app_name}-api-id"}))
# }