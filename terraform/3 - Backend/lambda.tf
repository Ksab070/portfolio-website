resource "aws_lambda_function" "visitor-update" {
  function_name = "visitorCounterUpdate"
  runtime       = "python3.13"
  role          = aws_iam_role.lambda-execution-role.arn
  filename      = "${path.module}/../../function.zip"
  handler = local.handler

  tags = merge(local.aws_tags, local.environment)
}
