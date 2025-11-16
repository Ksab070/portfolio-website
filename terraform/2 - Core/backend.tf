#### IAM Section ####

# IAM policy for Lambda execution
data "aws_iam_policy_document" "basic_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM policy document for dynamodb list and update
data "aws_iam_policy_document" "role_for_dynamodb_update" {
  statement {
    effect = "Allow"

    resources = [aws_dynamodb_table.dynamodb-table.arn]

    actions = ["dynamodb:UpdateItem",
    "dynamodb:GetItem"]
  }
}

# Create the policy for dynamodb
resource "aws_iam_policy" "policy-for-dynamodb" {
  policy = data.aws_iam_policy_document.role_for_dynamodb_update.json
  name = "dynamodb_policy"
  lifecycle {
    create_before_destroy = true
  }
}

# Create the execution role for lambda 
resource "aws_iam_role" "lambda-execution-role" {
  assume_role_policy = data.aws_iam_policy_document.basic_assume_role.json
  name               = local.dynamodb_role_name
}

# Attach the dynamodb policy to our execution role
resource "aws_iam_role_policy_attachment" "attach-dynamodb-role" {
  policy_arn = aws_iam_policy.policy-for-dynamodb.arn
  role = aws_iam_role.lambda-execution-role.name
} 

#### DynamoDB Section ####

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

#### Lambda Section ####

resource "aws_lambda_function" "visitor-update" {
  function_name = "visitorCounterUpdate"
  runtime       = "python3.13"
  role          = aws_iam_role.lambda-execution-role.arn
  filename      = "${path.module}/../../function.zip"
  handler = local.handler

  tags = merge(local.aws_tags, local.environment)
}

### API Gateway Section ####

resource "aws_apigatewayv2_api" "views-api" {
  name = "views-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "default-route" {
  api_id = aws_apigatewayv2_api.views-api.id
  route_key = "ANY /api"
  target = "integrations/${aws_apigatewayv2_integration.lambda-integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.views-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-integration" {
  api_id = aws_apigatewayv2_api.views-api.id
  integration_uri = aws_lambda_function.visitor-update.invoke_arn
  integration_type = "AWS_PROXY"
}


resource "aws_lambda_permission" "allow_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-update.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.views-api.execution_arn}/*/*"
}

