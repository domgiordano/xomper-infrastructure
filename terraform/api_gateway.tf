#*************************
# API Gateway
#*************************

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "XomifyAPI"
  description = "Xomify API Gateway"
  tags        = local.standard_tags
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
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'GET,POST,OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

#*************************
# Player Data
#*************************

resource "aws_api_gateway_resource" "player_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "player"
}

module "get_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.player_resource.id
  path_part               = "data"
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_player_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "post_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_player_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "POST"
  allow_methods           = ["POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_player_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "options_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_player_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "OPTIONS"
  allow_methods           = ["OPTIONS", "GET", "POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "MOCK"
  integration_http_method = "OPTIONS"
  uri                     = ""
  authorization           = "NONE"
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

#*************************
# User Data
#*************************

resource "aws_api_gateway_resource" "user_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "user"
}

module "get_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.user_resource.id
  path_part               = "data"
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_user_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "post_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_user_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "POST"
  allow_methods           = ["POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_user_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "options_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_user_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "OPTIONS"
  allow_methods           = ["OPTIONS", "GET", "POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "MOCK"
  integration_http_method = "OPTIONS"
  uri                     = ""
  authorization           = "NONE"
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

#*************************
# League Data
#*************************

resource "aws_api_gateway_resource" "league_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "league"
}

module "get_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.league_resource.id
  path_part               = "data"
  modify_api_resource     = false
  http_method             = "GET"
  allow_methods           = ["GET"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_league_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "post_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_league_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "POST"
  allow_methods           = ["POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_league_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

module "options_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_league_data_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "OPTIONS"
  allow_methods           = ["OPTIONS", "GET", "POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "MOCK"
  integration_http_method = "OPTIONS"
  uri                     = ""
  authorization           = "NONE"
  standard_tags           = local.standard_tags
  allow_origin            = "*"
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
    aws_api_gateway_resource.player_resource,
    module.get_player_data_endpoint,
    module.post_player_data_endpoint,
    module.options_player_data_endpoint,
    aws_api_gateway_resource.user_resource,
    module.get_user_data_endpoint,
    module.post_user_data_endpoint,
    module.options_user_data_endpoint,
    aws_api_gateway_resource.league_resource,
    module.get_league_data_endpoint,
    module.post_league_data_endpoint,
    module.options_league_data_endpoint
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
