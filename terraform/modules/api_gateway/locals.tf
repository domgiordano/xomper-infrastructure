# ---------------------------------------------------------
# Locals for API Gateway module
# ---------------------------------------------------------

locals {
  # Effective resource_id: if modifying/creating a new resource, use the new resource's ID
  # otherwise use the parent_resource_id
  resource_id = var.modify_api_resource && length(aws_api_gateway_resource.api_resource) > 0 ? aws_api_gateway_resource.api_resource[0].id : var.parent_resource_id
}