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
