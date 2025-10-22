import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("visitorCounter")


def lambda_handler(event, context):
    try:
        # Update the 'count' attribute atomically
        response = table.update_item(
            Key={"id": "views"},
            UpdateExpression="SET #c = if_not_exists(#c, :start) + :inc",
            ExpressionAttributeNames={
                "#c": "count"  # Map #c to the reserved word 'count'
            },
            ExpressionAttributeValues={":inc": 1, ":start": 0},
            ReturnValues="UPDATED_NEW",
        )

        # Get the updated count value from the response
        new_count = response["Attributes"]["count"]  # Use the alias #c here

        # Return a proper HTTP response for API Gateway
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",  # Allow CORS
                "Content-Type": "application/json",
            },
            "body": json.dumps({"views": int(new_count)}),
        }

    except Exception as e:
        # Handle errors and return a 500 response with the error message
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)}),
        }
