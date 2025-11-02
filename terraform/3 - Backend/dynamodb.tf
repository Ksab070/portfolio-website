resource "aws_dynamodb_table" "dynamodb-table" {
  name = local.dynamodb_table_name

  # On demand capacity
  billing_mode = "PAY_PER_REQUEST"

  # Primary key
  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = merge(local.aws_tags, local.environment)

}


resource "aws_dynamodb_table_item" "count-attribute" {
  table_name = aws_dynamodb_table.dynamodb-table.name

  # need to give primary key here as well, if an incorrect one is given here it will throw an error stating incorrect schema
  hash_key = "id"

  # Define the table items like this
  item = <<EOF
{
  "id": {"S": "views"},
  "count": {"N": "0"}
}
EOF
}
