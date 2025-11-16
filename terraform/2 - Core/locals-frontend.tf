terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


locals {
  aws_tags = {
    "Terraform" : "Yes"
  }

  environment = {
    "production" : "Yes"
  }

  # This sets the front-end path for upload to s3 bucket
  frontend_files = fileset("${path.module}/../../front-end", "**")
  frontend_path  = "${path.module}/../../front-end"
  s3_bucket_name = "my-app-bucket-sk"
  s3_origin_id   = "my-s3-origin"
  apigateway_origin_id = "apigateway-origin"
  domain         = "cloud-personal.com"
  app-domain     = "app.${local.domain}"
}

data "aws_acm_certificate" "acm-cert-for-app-domain" {
  domain   = local.app-domain
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "app-domain" {
  name = local.app-domain
  private_zone = false
}
