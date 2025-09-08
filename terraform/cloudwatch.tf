
## DYNAMODB
resource "aws_cloudwatch_log_group" "wrapped_db_log_group" {
    name = aws_dynamodb_table.wrapped.id
    retention_in_days = 14
    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-wrapped"}))
}

