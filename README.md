Architecture

| Component                       | Purpose                                                 |
| ------------------------------- | ------------------------------------------------------- |
| **S3 Bucket**                   | Serves the static HTML/CSS/JS site                      |
| **CloudFront**                  | CDN + HTTPS support                                     |
| **Route 53**                    | DNS + subdomain delegation                              |
| **API Gateway (HTTP API)**      | Endpoint for the backend (visitor counter, form, etc.)  |
| **Lambda Function**             | Backend logic (Increment visitor count)                 |
| **DynamoDB Table**              | Stores your visitor count                               |


# Cloud Resume Challenge – AWS | Terraform | CloudFront | Lambda | API Gateway | Cloudflare

This repository contains my implementation of the **Cloud Resume Challenge**, built using a fully-serverless architecture on AWS and automated with **Terraform**. The frontend is hosted on S3 behind CloudFront, the backend uses Lambda + API Gateway for the visitor counter, and DNS is handled via Route53 and Cloudflare. All infrastructure is provisioned through Terraform with a remote S3 backend.

## 📌 Architecture Overview

### Frontend Hosting
- Static resume website stored in a **private S3 bucket**
- Delivered via **Amazon CloudFront (CDN)**
- CloudFront uses **Origin Access Control (OAC)** to securely access the private bucket
- Provides caching, security, and global performance improvements

### Visitor Counter Backend
- Built using:
  - **AWS Lambda** (Python)
  - **API Gateway** (REST API)
- API Gateway ensures:
  - The frontend never interacts directly with Lambda
  - Additional security through throttling, validation, and IAM role isolation
  - Potential for future API expansion without modifying the frontend

### DNS & SSL Certificates
- Subdomain `app.cloud-personal.com` is hosted on **Route53**
- Parent domain DNS is managed in **Cloudflare**
- Terraform is used to:
  - Delegate the subdomain to Route53  
  - Manage Cloudflare DNS records  
  - Generate an **ACM certificate** for HTTPS

### Infrastructure as Code (IaC)
- Managed entirely using **Terraform**
- Terraform backend uses an S3 bucket created by a bash script
- The deployment is split into:
  - **DNS layer** (Cloudflare, Route53, ACM)
  - **Core infrastructure** (S3, CloudFront, Lambda, API Gateway)
- The design supports easy integration with GitHub Actions for CI/CD

## 🚀 Manual Deployment (Without CI/CD)

Follow these steps to deploy the project manually.

### 1️⃣ Configure AWS CLI Credentials

```bash
aws configure
```

### 2️⃣ Export Cloudflare API Token

```bash
export CLOUDFLARE_API_TOKEN=<your-token>
```

Token permissions:
- Zone:Read  
- Zone:DNS:Edit  

### 3️⃣ Deploy DNS Layer (Terraform – Step 1)

```bash
cd terraform/"1 - DNS"
terraform init
terraform apply -target=aws_route53_zone.app -auto-approve
terraform apply -auto-approve
```

### 4️⃣ Deploy Core Infrastructure (Terraform – Step 2)

```bash
cd ../"2 - Core"
bash ../create-bucket.sh
terraform init
terraform apply -auto-approve
```
