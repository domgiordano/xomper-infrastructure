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