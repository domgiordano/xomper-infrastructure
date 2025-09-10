
## DYNAMODB
resource "aws_cloudwatch_log_group" "player_data_db_log_group" {
    name = aws_dynamodb_table.player_data.id
    retention_in_days = 14
    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-player_data"}))
}

## APIGW
resource "aws_cloudwatch_log_group" "api_log_group" {
    name = aws_api_gateway_rest_api.api_gateway.id
    retention_in_days = 14
    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-APIGW-Access-Logs"}))
}

## CHRON JOB - WRAPPED
resource "aws_cloudwatch_event_rule" "update_player_data_schedule" {
  name        ="${var.app_name}-update-player-data-schedule"
  description = "Trigger Wrapped Lambda function on the first day of every month"
  schedule_expression = "cron(0 6 * * 2,4,6)"  # Runs at midnight on the first day of every month
}

resource "aws_cloudwatch_event_target" "update_player_data_target" {
  rule      = aws_cloudwatch_event_rule.update_player_data_schedule.name
  target_id = "${var.app_name}-update-player-data-target-id"
  arn       = aws_lambda_function.update_player_data.arn
}
