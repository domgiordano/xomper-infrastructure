# ---------------------------------------------------------
# Resource (optional)
# ---------------------------------------------------------
resource "aws_api_gateway_resource" "api_resource" {
  count       = var.modify_api_resource ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = coalesce(var.path_part, lower(var.http_method))
}

# ---------------------------------------------------------
# Method (GET/POST)
# ---------------------------------------------------------
resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.rest_api_id
  resource_id   = local.resource_id
  http_method   = var.http_method
  authorization = var.authorization
  authorizer_id = var.authorization == "CUSTOM" ? var.authorizer_id : null
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_method.method.resource_id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = var.integration_http_method
  type                    = var.integration_type
  uri                     = var.uri
  request_templates       = var.request_templates
  credentials             = var.integration_credentials
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

# ---------------------------------------------------------
# Method Response + Integration Response
# ---------------------------------------------------------
resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_method.method.resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = var.response_http_status_code

  response_models = {
    "application/json" = var.response_model
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_method.method.resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allow_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allow_methods)}'"
  }

  response_templates = var.response_templates
}

# ---------------------------------------------------------
# OPTIONS (CORS Preflight)
# ---------------------------------------------------------
resource "aws_api_gateway_method" "options" {
  count         = var.enable_cors ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = local.resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  count                  = var.enable_cors ? 1 : 0
  rest_api_id            = var.rest_api_id
  resource_id            = aws_api_gateway_method.options[0].resource_id
  http_method            = aws_api_gateway_method.options[0].http_method
  type                   = "MOCK"
  integration_http_method = "OPTIONS"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
  content_handling     = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "options_response" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_method.options[0].resource_id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_method.options[0].resource_id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = aws_api_gateway_method_response.options_response[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allow_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allow_methods)}'"
  }
}
