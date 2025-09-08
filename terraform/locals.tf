locals {
    domain_name = "${var.app_name}${var.domain_suffix}"

  # Get the AWS product account id
    web_app_account_id = data.aws_caller_identity.web_app_account.account_id
    standard_tags = {
        "source" = "terraform",
        "app_name" = var.app_name
    }

}
