provider "aws" {
  region = "ap-southeast-1"
  alias = "test"
  assume_role {
    role_arn = "arn:aws:iam::${var.accountId}:role/${var.env}-cross-account-infra-deployment-role"
  }
}

