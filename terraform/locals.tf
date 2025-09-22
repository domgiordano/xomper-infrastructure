locals {
  domain_name = "${var.app_name}${var.domain_suffix}"

  # Get the AWS product account id
  web_app_account_id = data.aws_caller_identity.web_app_account.account_id
  standard_tags = {
      "source" = "terraform",
      "app_name" = var.app_name
  }

 # LAMBDAS
 lambda_variables = {
   APP_NAME = var.app_name
   DYNAMODB_KMS_ALIAS = aws_kms_alias.xomper_dynamodb.name
   PLAYER_DATA_TABLE_NAME = aws_dynamodb_table.player_data.id
   USER_DATA_TABLE_NAME = aws_dynamodb_table.user_data.id
   LEAGUE_DATA_TABLE_NAME = aws_dynamodb_table.league_data.id
   AWS_ACCOUNT_ID = data.aws_caller_identity.web_app_account.account_id
 }

 # API GW
 api_allow_headers = ["Authorization", "Content-Type", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token",  "Origin", "Accept", "Access-Control-Allow-Origin", "Accept-Language"]
 api_allow_origin  = "https://xomper.com" #,http://localhost:4200

}
