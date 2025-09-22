#*************************
# USER
#*************************
resource "aws_lambda_permission" "update_user"{
  statement_id  = "AllowUpdateUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.user_resource.path_part}/update"
}
resource "aws_lambda_permission" "login_user"{
  statement_id  = "AllowLoginUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.user_resource.path_part}/login"
}
resource "aws_lambda_permission" "get_user"{
  statement_id  = "AllowGetUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.user_resource.path_part}/data"
}

#*************************
# LEAGUE
#*************************
resource "aws_lambda_permission" "update_leauge"{
  statement_id  = "AllowUpdateLeague"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_league_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.league_resource.path_part}/update"
}
resource "aws_lambda_permission" "get_league"{
  statement_id  = "AllowGetLeague"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_league_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.league_resource.path_part}/data"
}

#*************************
# PLAYER
#*************************
resource "aws_lambda_permission" "update_player"{
  statement_id  = "AllowUpdatePlayer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_player_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.player_resource.path_part}/update"
}
resource "aws_lambda_permission" "get_player"{
  statement_id  = "AllowGetPlayer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_player_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.player_resource.path_part}/data"
}

