resource "aws_lambda_function" "update_player_data" {

  function_name     = "${var.app_name}-update-player-data"
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

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = merge(local.standard_tags, tomap({"name" = "${var.app_name}-update-player-data"}))



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

resource "aws_lambda_permission" "chron_job" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_player_data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.update_player_data_schedule.arn
}

resource "aws_lambda_function" "get_player_data" {

  function_name     = "${var.app_name}-get-player-data"
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

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = merge(local.standard_tags, tomap({"name" = "${var.app_name}-get-player-data"}))



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