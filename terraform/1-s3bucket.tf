resource "random_id" "suffix" {
  byte_length = 4
}

# Create the bucket
resource "aws_s3_bucket" "bucket" {
  # The random id string adds a random character, as s3 bucket names needs to be globally unique
  bucket = "my-app-bucket-${random_id.suffix.hex}"

  tags = merge(local.aws_tags, local.environment)
}

# Upload frontend on the bucket
resource "aws_s3_object" "upload_frontend" {
  for_each = { for file in local.frontend_files : file => file }

  bucket = aws_s3_bucket.bucket.id
  key    = each.key
  source = "${path.module}/../front-end/${each.key}"
  etag   = filemd5("${path.module}/../front-end/${each.key}")

  # Detect Content-Type automatically using MIME lookup, copied from chatgpt :)
  content_type = lookup(
    {
      html  = "text/html"
      css   = "text/css"
      js    = "application/javascript"
      json  = "application/json"
      png   = "image/png"
      jpg   = "image/jpeg"
      jpeg  = "image/jpeg"
      svg   = "image/svg+xml"
      woff  = "font/woff"
      woff2 = "font/woff2",
      pdf   = "application/pdf",
      py    = "text/x-python"
    },
    regex("[^.]+$", each.value),
    "application/octet-stream"
  )

}
