# ---------------------------------------------------------
# Locals for API Gateway module
# ---------------------------------------------------------

locals {
  resource_id = var.modify_api_resource ? aws_api_gateway_resource.api_resource[0].id : var.parent_resource_id
}
