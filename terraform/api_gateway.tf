#*************************
# API Gateway
#*************************

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

#*************************
# Gateway Responses (CORS for errors)
#*************************

resource "aws_api_gateway_gateway_response" "api_server_error_response" {
  status_code   = "500"
  response_type = "DEFAULT_5XX"
  response_templates = {
    "application/json" = "{\"message\": \"$context.error.validationErrorString\"}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'https://xomper.com'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'GET,POST,OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

#*************************
# Player Endpoints
#*************************

# /get-player
resource "aws_api_gateway_resource" "player_get_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "get-player"
}

module "get_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.player_get_resource.id
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_player_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

# /update-player
resource "aws_api_gateway_resource" "player_post_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "update-player"
}

module "post_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.player_post_resource.id
  modify_api_resource     = false
  http_method             = "POST"
  allow_methods           = ["POST", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_player_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

#*************************
# Login Endpoints
#*************************f


# /login
resource "aws_api_gateway_resource" "login_post_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "login"
}

module "post_login_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.login_post_resource.id
  modify_api_resource     = false
  http_method             = "POST"
  allow_methods           = ["POST", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.user_login.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

#*************************
# User Endpoints
#*************************

# /get-user
resource "aws_api_gateway_resource" "user_get_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "get-user"
}

module "get_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.user_get_resource.id
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_user_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

# /update-user
resource "aws_api_gateway_resource" "user_post_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "update-user"
}

module "post_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.user_post_resource.id
  modify_api_resource     = false
  http_method             = "POST"
  allow_methods           = ["POST", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_user_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

#*************************
# League Endpoints
#*************************

# /get-league
resource "aws_api_gateway_resource" "league_get_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "get-league"
}

module "get_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.league_get_resource.id
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_league_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

# /update-league
resource "aws_api_gateway_resource" "league_post_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "update-league"
}

module "post_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.league_post_resource.id
  modify_api_resource     = false
  http_method             = "POST"
  allow_methods           = ["POST", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_league_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "https://xomper.com"
  enable_cors             = true
}

#*************************
# Deployment
#*************************

resource "aws_api_gateway_deployment" "api_deploy" {
  variables = {
    integrations = "Deployed at: ${timestamp()}"
  }
  triggers = {
    redeployment = sha1(jsonencode([timestamp()]))
  }
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  description = "Deployed at ${timestamp()}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_resource.player_get_resource,
    aws_api_gateway_resource.player_post_resource,
    module.get_player_data_endpoint,
    module.post_player_data_endpoint,
    aws_api_gateway_resource.user_get_resource,
    aws_api_gateway_resource.user_post_resource,
    module.get_user_data_endpoint,
    module.post_user_data_endpoint,
    aws_api_gateway_resource.league_get_resource,
    aws_api_gateway_resource.league_post_resource,
    module.get_league_data_endpoint,
    module.post_league_data_endpoint,
    aws_api_gateway_resource.login_post_resource,
    module.post_login_data_endpoint
  ]
}

#*************************
# Stages
#*************************

resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "prod"
  tags          = local.standard_tags
}
