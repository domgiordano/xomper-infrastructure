variable "rest_api_id" {
  description = "REST API ID"
  type        = string
}

variable "parent_resource_id" {
  description = "Resource ID of parent resource to be used."
  type        = string
}

variable "path_part" {
  description = "Path part of the resource to be created."
  type        = string
  default     = ""
}

variable "modify_api_resource" {
  description = <<EOT
If true, create a new API resource under parent_resource_id + path_part.
If false, reuse the existing parent_resource_id directly.
EOT
  type    = bool
  default = false
}

variable "http_method" {
  description = "HTTP method associated with the resource request"
  type        = string
  default     = "ANY"
}

variable "authorization" {
  description = "Authorization type for the method. Valid values: NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS"
  type        = string
  default     = "NONE"
}

variable "authorizer_id" {
  description = "Authorizer ID to be used when authorization is CUSTOM or COGNITO_USER_POOLS."
  type        = string
  default     = ""
}

variable "authorization_scopes" {
  description = "Authorization scopes when using COGNITO_USER_POOLS."
  type        = list(string)
  default     = []
}

variable "request_validator_id" {
  description = "Request validator during resource method execution."
  type        = string
  default     = ""
}

variable "request_models" {
  description = "Map of request models (key = content type, value = model)."
  type        = map(string)
  default     = {}
}

variable "request_templates" {
  description = "Map of request templates (key = content type, value = template)."
  type        = map(string)
  default     = {}
}

variable "method_request_parameters" {
  description = "Request parameters (path/query) for the method."
  type        = map(bool)
  default     = {}
}

variable "integration_type" {
  description = "Integration type: AWS, AWS_PROXY, HTTP, HTTP_PROXY, MOCK."
  type        = string
}

variable "integration_http_method" {
  description = "Integration HTTP method (required for AWS, AWS_PROXY, HTTP, HTTP_PROXY). Lambdas require POST."
  type        = string
  default     = ""
}

variable "integration_credentials" {
  description = "For AWS integrations: IAM role ARN assumed by API Gateway."
  type        = string
  default     = null
}

variable "integration_request_parameters" {
  description = "Integration request parameters (map of request parameters)."
  type        = map(string)
  default     = {}
}

variable "uri" {
  description = "Integration URI (Lambda ARN, HTTP endpoint, or AWS service ARN)."
  type        = string
  default     = ""
}

variable "response_http_status_code" {
  description = "Default HTTP status code for method response."
  type        = string
  default     = "200"
}

variable "response_model" {
  description = "Response model name (default = Empty)."
  type        = string
  default     = "Empty"
}

variable "response_parameters" {
  description = "Additional response parameters (map of response headers)."
  type        = map(string)
  default     = {}
}

variable "response_templates" {
  description = "Integration response templates (key = content type, value = template)."
  type        = map(string)
  default     = {
    "application/json" = ""
  }
}

# -------------------
# CORS settings
# -------------------
variable "enable_cors" {
  description = "Whether to create OPTIONS method for CORS"
  type        = bool
  default     = true
}
variable "allow_headers" {
  description = "CORS: Access-Control-Allow-Headers values."
  type        = list(string)
  default     = ["Authorization", "Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "X-Api-Key"]
}

variable "allow_methods" {
  description = "CORS: Access-Control-Allow-Methods values."
  type        = list(string)
  default     = ["OPTIONS", "HEAD", "GET", "POST", "PUT"]
}

variable "allow_origin" {
  description = "CORS: Allowed origin(s). Use '*' or a specific domain. (You can extend to list later if needed)."
  type        = string
  default     = "*"
}

# -------------------
# Tags
# -------------------
variable "standard_tags" {
  description = "Standard tags for resources"
  type        = map(string)
  default     = {}
}