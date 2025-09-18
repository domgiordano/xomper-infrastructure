resource "aws_dynamodb_table" "player_data"{
    name = "${var.app_name}-player-data"
    billing_mode = "PAY_PER_REQUEST"
    read_capacity = 0
    write_capacity = 0
    hash_key = "player_id"

    server_side_encryption {
      enabled = true
      kms_key_arn = aws_kms_alias.xomper_dynamodb.target_key_arn
    }

    point_in_time_recovery {
        enabled = true
    }

    attribute {
        name = "player_id"
        type = "S"
    }

    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-player-data"}))

}

resource "aws_dynamodb_table" "user_data"{
    name = "${var.app_name}-user-data"
    billing_mode = "PAY_PER_REQUEST"
    read_capacity = 0
    write_capacity = 0
    hash_key = "user_id"

    server_side_encryption {
      enabled = true
      kms_key_arn = aws_kms_alias.xomper_dynamodb.target_key_arn
    }

    point_in_time_recovery {
        enabled = true
    }

    attribute {
        name = "user_id"
        type = "S"
    }

    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-user-data"}))

}

