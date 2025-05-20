terraform {
  backend "s3" {
    bucket         = "testing-terraform-starfish"
    key            = ""
    region         = "ap-southeast-1"
    dynamodb_table = "state-locking"
  }
}

