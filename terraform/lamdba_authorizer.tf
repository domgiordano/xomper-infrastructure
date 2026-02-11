## Resources for API Gateway Lambda Authorization
resource "aws_lambda_function" "authorizer" {
  function_name     = "${var.app_name}-authorizer"
  description       = "Lambda Authorizer for ${var.app_name}"
  filename          = "./templates/lambda_stub.zip"
  source_code_hash  = filebase64sha256("./templates/lambda_stub.zip")
  handler           = "handler.handler"
  layers            = [aws_lambda_layer_version.lambda_layer.arn]
  runtime           = var.lambda_runtime
  memory_size       = 1024
  timeout           = 900
  role              = aws_iam_role.lambda_role.arn

  environment {
    variables = local.lambda_variables
  }
  tags = merge(local.standard_tags, tomap({"name" = "${var.app_name}-authorizer"}))

  tracing_config {
    mode = var.lambda_trace_mode
  }

  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash,
      layers
    ]
  }
  depends_on = [
    aws_iam_role_policy.lambda_role_policy,
    aws_iam_role.lambda_role
  ]

}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                   = "${var.app_name}-Api-Gateway-Lambda-Authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api_gateway.id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.lambda_role.arn
}

#Give api gateway permission to invoke lambda authorizer
resource "aws_lambda_permission" "lambda_authorizer_handler_permission" {
  statement_id  = "AllowExecFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
}
