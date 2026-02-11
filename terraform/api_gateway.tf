# ## API Gateway Resources

resource "aws_api_gateway_account" "api_gateway_account" {
 cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name                     = "${var.app_name}-api"
  description              = "API Gateway for ${var.app_name}"
  binary_media_types       = ["multipart/form-data"]
  minimum_compression_size = 5242880
  tags                     = merge(local.standard_tags, tomap({"name" = "${var.app_name}-api-gateway"}))

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name              = local.domain_name
  regional_certificate_arn = aws_acm_certificate.web_app.arn
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Name = "apig-domain-name"
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
}

## Stage and Deployment of API Gateway
resource "aws_api_gateway_stage" "api_stage" {
 stage_name    = "dev"
 rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
 deployment_id = aws_api_gateway_deployment.api_deploy.id
 tags          = merge(local.standard_tags, tomap({"name" = "dev"}))

 access_log_settings {
   destination_arn = aws_cloudwatch_log_group.api_log_group.arn
   format          = "$context.identity.sourceIp $context.identity.caller  $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId $context.extendedRequestId"
 }
}

resource "aws_api_gateway_deployment" "api_deploy" {
 variables = {
  integrations =  "Deployed at: ${timestamp()}"
 }
 triggers    = {
		redeployment = sha1(jsonencode([timestamp()]))
	}
 rest_api_id        = aws_api_gateway_rest_api.api_gateway.id
 //stage_description  = "Dev Deployed at: ${timestamp()}" // forces to 'create' a new deployment each run
 description        = "Deployed at ${timestamp()}"
 lifecycle {
   create_before_destroy = true
 }
  depends_on = [
    aws_api_gateway_resource.wrapped_resource,
    aws_api_gateway_resource.user_resource,
    aws_api_gateway_resource.release_radar_resource,
    aws_api_gateway_resource.friends_resource,
    aws_api_gateway_resource.groups_resource,

    module.wrapped_endpoints,
    module.user_endpoints,
    module.release_radar_endpoints,
    module.friends_endpoints,
    module.ratings_endpoints,
    module.groups_endpoints
  ]
}

# Enable Logging
resource "aws_api_gateway_method_settings" "api_gateway_method_setting" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }

  depends_on = [aws_api_gateway_stage.api_stage]
}


#*************************
# Gateway Responses
#*************************

resource "aws_api_gateway_gateway_response" "api_server_error_response" {
  status_code   = "500"
  response_type = "DEFAULT_5XX"
  response_templates = {
    "application/json" = "{\"message\": \"$context.error.validationErrorString\"}"
  }
  # CORS
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_gateway_response" "api_client_error_response" {
  status_code   = "403"
  response_type = "DEFAULT_4XX"
  response_templates = {
    "application/json" = "{\"message\": \"$context.error.message\"}"
  }
  # CORS
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

