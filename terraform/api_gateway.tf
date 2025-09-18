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
    aws_api_gateway_resource.player_resource,
    module.get_player_data_endpoint,
    module.post_player_data_endpoint,
    aws_api_gateway_resource.user_resource,
    module.get_user_data_endpoint,
    module.post_user_data_endpoint,
    aws_api_gateway_resource.league_resource,
    module.get_league_data_endpoint,
    module.post_league_data_endpoint
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

#**********************
# PLAYER DATA
# /player/data
#**********************

resource "aws_api_gateway_resource" "player_resource" {
  path_part   = "player"
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

# GET /player/data
module "get_player_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.player_resource.id
  path_part               = "data"
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_player_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# POST /player/data
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

# AWS Permissions - user table
resource "aws_lambda_permission" "update_player_table_data_post_permission"{
  statement_id  = "AllowPostUpdatePlayerDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_player_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.player_resource.path_part}/data"
}
resource "aws_lambda_permission" "get_player_table_data_post_permission"{
  statement_id  = "AllowGetPlayerDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_player_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.player_resource.path_part}/data"
}

#**********************
# USER DATA
# /user/data
#**********************

resource "aws_api_gateway_resource" "user_resource" {
  path_part   = "user"
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

# GET /user/data
module "get_user_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.user_resource.id
  path_part               = "data"
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_user_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# POST /user/data
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

# GET /user/login
module "get_user_login_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.user_resource.id
  path_part               = "login"
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.user_login.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# POST /user/login
module "post_user_login_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = module.get_user_login_endpoint.api_gateway_resource_id
  modify_api_resource     = true
  http_method             = "POST"
  allow_methods           = ["POST"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.user_login.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# AWS Permissions - user table
resource "aws_lambda_permission" "update_user_table_data_post_permission"{
  statement_id  = "AllowPostUpdateUserDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.user_resource.path_part}/data"
}
resource "aws_lambda_permission" "get_user_table_data_post_permission"{
  statement_id  = "AllowGetUserDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.user_resource.path_part}/data"
}

resource "aws_lambda_permission" "update_user_login_post_permission"{
  statement_id  = "AllowPostUpdateUserLoginTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.user_resource.path_part}/login"
}
resource "aws_lambda_permission" "get_user_login_post_permission"{
  statement_id  = "AllowGetUserLoginTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.user_resource.path_part}/login"
}

#**********************
# LEAGUE DATA
# /league/data
#**********************

resource "aws_api_gateway_resource" "league_resource" {
  path_part   = "league"
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

# GET /league/data
module "get_league_data_endpoint" {
  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.league_resource.id
  path_part               = "data"
  http_method             = "GET"
  allow_methods           = ["GET", "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.get_league_data.invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# POST /league/data
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

# AWS Permissions - league table
resource "aws_lambda_permission" "update_league_table_data_post_permission"{
  statement_id  = "AllowPostUpdateLeagueDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_league_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.league_resource.path_part}/data"
}
resource "aws_lambda_permission" "get_league_table_data_post_permission"{
  statement_id  = "AllowGetLeagueDataTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_league_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.league_resource.path_part}/data"
}
