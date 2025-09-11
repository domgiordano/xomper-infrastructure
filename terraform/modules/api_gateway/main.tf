# Setting up resource, method, integration, method response, and integration response
resource "aws_api_gateway_resource" "api_gateway_resource" {
  count       = var.modify_api_resource ? 0 : 1
  parent_id   = var.parent_resource_id
  path_part   = var.path_part
  rest_api_id = var.rest_api_id
} 

##### CORS #####
resource "aws_api_gateway_method" "options_method" {
  count            = var.modify_api_resource ? 0 : 1
  authorization    = "NONE"
  http_method      = "OPTIONS"
  resource_id      = local.resource_id
  rest_api_id      = var.rest_api_id
}

resource "aws_api_gateway_integration" "options_integration" {
  count             = var.modify_api_resource ? 0 : 1
  http_method       = aws_api_gateway_method.options_method[0].http_method
  type              = "MOCK"
  request_templates = {
    "application/json" : "{ \"statusCode\": 200 }"
  }
  content_handling = "CONVERT_TO_TEXT"
  resource_id      = local.resource_id
  rest_api_id      = var.rest_api_id
  depends_on       = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_method_response" "options_method_response" {
  count       = var.modify_api_resource ? 0 : 1
  http_method = aws_api_gateway_method.options_method[0].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Credentials"  = true
  }

  resource_id = local.resource_id
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  count       = var.modify_api_resource ? 0 : 1
  http_method = aws_api_gateway_method.options_method[0].http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${local.origins_list[0]}'"
    "method.response.header.Access-Control-Allow-Credentials"  = "'true'"
  }

  response_templates = {
    "application/json" : local.cors_vtl
  }

  resource_id = local.resource_id
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_method.options_method, aws_api_gateway_method_response.options_method_response]
}

##### RESOURCE CALL #####
resource "aws_api_gateway_method" "api_gateway_method" {
  authorization        = var.authorization
  authorizer_id        = var.authorizer_id
  request_validator_id = var.request_validator_id
  http_method          = var.http_method 
  request_parameters   = var.method_request_parameters
  request_models       = var.request_models
  resource_id          = local.resource_id
  rest_api_id          = var.rest_api_id
  authorization_scopes = var.authorization_scopes
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  http_method = aws_api_gateway_method.api_gateway_method.http_method 

  # integration with backend service
  type                    = var.integration_type
  integration_http_method = var.integration_http_method
  uri                     = var.uri
  request_templates       = var.request_templates
  credentials             = var.integration_credentials
  passthrough_behavior    = var.integration_type == "AWS" ? "NEVER" : "WHEN_NO_TEMPLATES"

  
  content_handling        = "CONVERT_TO_TEXT"
  resource_id             = local.resource_id
  rest_api_id             = var.rest_api_id
  depends_on              = [aws_api_gateway_method.api_gateway_method]
}

resource "aws_api_gateway_method_response" "api_gateway_method_response" {
  http_method         = aws_api_gateway_method.api_gateway_method.http_method
  status_code         = "200"
  
  response_models = {
         "application/json" = var.response_model
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  resource_id = local.resource_id
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_method.api_gateway_method]
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response" { 
  http_method        = aws_api_gateway_method.api_gateway_method.http_method
  status_code        = aws_api_gateway_method_response.api_gateway_method_response.status_code
  response_templates = var.response_templates

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${local.origins_list[0]}'"
  }
  resource_id = local.resource_id
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_integration.api_gateway_integration, aws_api_gateway_method.api_gateway_method, aws_api_gateway_method_response.api_gateway_method_response]
}