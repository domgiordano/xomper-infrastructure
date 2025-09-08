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
  description = "Use true if adding a new HTTP verb on an existing API resource. If false, parent_resource_id will be used as parent and path_part is required"
  type        = bool
  default     = false
}

variable "authorization" {
  description = "Type of authorization used for method. NONE, CUSTOM, AWS_IAM, and COGNITO_USER_POOLS are valid values."
  type        = string
  default     = "NONE"
}

variable "authorizer_id" {
  description = "The authorizer id to be used when authorization is CUSTOM or COGNITO_USER_POOLS."
  type        = string
  default     = ""
}

variable "request_validator_id" {
  description = "Request validator during resource method execution."
  type        = string
  default     = ""
}

variable "request_models" {
  description = "A map of request models used for request's content type, where key is the content type and value is the model."
  type        = map(string)
  default     = {}
}

variable "request_templates" {
  description = "A map of request templates used for request's content type, where key is the content type and value is the model."
  type        = map(string)
  default     = {}
}

variable "http_method" {
  description = "Http method associated with the resource request"
  type        = string
  default     = "ANY"
}

variable "method_request_parameters" {
  description = "Path or query parameters associated with resource"
  type        = map(bool)
  default     = {}
}

variable "integration_http_method" {
  description = "Integration HTTP method specifying how API Gateway will interact with backend. Required for AWS, AWS_PROXY, HTTP, or HTTP_PROXY. Lambdas may only be invoked via POST"
  type        = string
  default     = ""
}

variable "integration_type" {
  description = "Resource integration type. Values values are HTTP, MOCK, AWS, AWS_PROXY, HTTP_PROXY"
  type        = string
}

variable "integration_credentials" {
  description = "For API Integration resource - if type AWS, need role ARN to call AWS resource"
  type        = string
  default     = null
}

variable "uri" {
  description = "Input's URI. Required if type is AWS, AWS_PROXY, HTTP, or HTTP_PROXY"
  type        = string
  default     = ""
}

variable "integration_request_parameters" {
  description = "Integration parameters for the request"
  type        = map(string)
  default     = {}
}

variable "response_http_status_code" {
  description = "The HTTP status code"
  type        = string
  default     = "200"
}

variable "response_model" {
  description = "response model"
  type        = string
  default     = "Empty"
}

variable "response_parameters" {
  description = "A map of response parameters that can be sent to the caller"
  type        = map(string)
  default     = {}
}

variable "response_templates" {
  description = "A map specifying the templates used to transform the integration response body"
  type        = map(string)
  default     = { "application/json" = "" }  
}

variable "allow_headers" {
  description = "List of Access-Control-Allow-Headers headers"
  type        = list(string)
  default     = ["Authorization", "Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "X-Api-Key"]
}

variable "allow_methods" {
  description = "List of Access-Control-Allow-Methods headers"
  type        = list(string)
  default     = ["OPTIONS", "HEAD", "GET", "POST", "PUT", "PATCH", "DELETE"]
}

variable "allow_origin" {
  description = "Comma-delimited string of allowed origins for CORS. Default to '*'"
  type        = string
  default     = "*"
}

variable "authorization_scopes" {
  description = "auth scopes"
  type        = list(string)
  default     = []
}

variable "standard_tags" {
  description = "Standard Tags for Resources"
  type        = map
}