locals {
  dynamodb_table_name = "visitorCounter"
  dynamodb_role_name = "lambda_execution_role"
  handler = "update_visitor_count.lambda_handler"
}
