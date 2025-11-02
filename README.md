Architecture

| Component                       | Purpose                                                 |
| ------------------------------- | ------------------------------------------------------- |
| **S3 Bucket**                   | Serves the static HTML/CSS/JS site                      |
| **CloudFront**                  | CDN + HTTPS support                                     |
| **Route 53**                    | DNS + subdomain delegation                              |
| **API Gateway (HTTP API)**      | Endpoint for the backend (visitor counter, form, etc.)  |
| **Lambda Function**             | Backend logic (Increment visitor count)                 |
| **DynamoDB Table**              | Stores your visitor count                               |
