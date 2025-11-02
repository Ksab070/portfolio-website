provider "aws" {
  region = "us-east-1"
}

locals {
  dynamodb_table_name = "visitorCounter"
  
  aws_tags = {
    "Terraform" : "Yes"
  }

  environment = {
    "production" : "Yes"
  }

  dynamodb_role_name = "lambda_execution_role"
  handler = "update_visitor_count.lambda_handler"
}
