#**********************
# Email
# /email
#**********************

resource "aws_api_gateway_resource" "email_resource" {
  path_part   = "email"
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

# Dynamically create endpoints for email lambdas
module "email_endpoints" {
  for_each = { for lambda in local.email_lambdas : lambda.name => lambda }

  source                  = "./modules/api_gateway"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  parent_resource_id      = aws_api_gateway_resource.email_resource.id
  path_part               = each.value.path_part
  http_method             = each.value.http_method
  allow_methods           = [each.value.http_method, "OPTIONS"]
  allow_headers           = local.api_allow_headers
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.email[each.key].invoke_arn
  authorization           = "CUSTOM"
  authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
  standard_tags           = local.standard_tags
  allow_origin            = "*"
}

# AWS Permissions /email
resource "aws_lambda_permission" "email_data_permission" {
  for_each      = { for lambda in local.email_lambdas : lambda.name => lambda }
  statement_id  = "AllowEmail${title(each.value.name)}Api"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email[each.value.name].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}
