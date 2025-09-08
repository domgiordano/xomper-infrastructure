terraform {
  backend "remote" {
    organization = "Domjgiordano"

    workspaces {
      name = "xomper-infrastructure"
    }
  }
}

data "aws_caller_identity" "web_app_account" {
  provider = aws
}
