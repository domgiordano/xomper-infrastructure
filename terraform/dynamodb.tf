# resource "aws_dynamodb_table" "leagues"{
#     name = "${var.app_name}-leagues"
#     billing_mode = "PAY_PER_REQUEST"
#     read_capacity = 0
#     write_capacity = 0
#     hash_key = "email"

#     server_side_encryption {
#       enabled = true
#       kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
#     }

#     point_in_time_recovery {
#         enabled = true
#     }

#     attribute {
#         name = "email"
#         type = "S"
#     }

#     tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-leagues"}))

# }
