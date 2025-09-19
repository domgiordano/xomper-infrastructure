locals {
  lambdas = {
    get_player_data    = aws_lambda_function.get_player_data
    update_player_data = aws_lambda_function.update_player_data
    get_user_data      = aws_lambda_function.get_user_data
    update_user_data   = aws_lambda_function.update_user_data
    get_league_data    = aws_lambda_function.get_league_data
    update_league_data = aws_lambda_function.update_league_data
    user_login         = aws_lambda_function.user_login
  }
}

resource "aws_lambda_permission" "api_gateway_permissions" {
  for_each      = local.lambdas
  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}