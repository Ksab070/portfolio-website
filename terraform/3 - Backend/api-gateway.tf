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


