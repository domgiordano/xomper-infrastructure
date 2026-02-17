# API Gateway Account (singleton per AWS account)
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

locals {
  email_endpoints = [
    for l in local.email_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.email[l.name].invoke_arn
    }
  ]
}

module "api" {
  source = "git::https://github.com/domgiordano/api-gateway-service.git?ref=v2.2.0"

  app_name              = var.app_name
  stage_name            = "dev"
  authorizer_invoke_arn = aws_lambda_function.authorizer.invoke_arn
  authorizer_role_arn   = aws_iam_role.lambda_role.arn
  tags                  = local.standard_tags
  allow_headers         = local.api_allow_headers
  allow_origin          = "*"

  domain_name     = local.domain_name
  certificate_arn = module.web.certificate_arn

  services = {
    email = {
      path_prefix = "email"
      endpoints   = local.email_endpoints
    }
  }
}
