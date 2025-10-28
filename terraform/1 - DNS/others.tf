terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
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
  zone_id      = "31b75f303b467246315ff1d5fe271fef"
  account_id   = "1cdd8c65585d05850ca3bb2548e5c6e7"
  domain = "cloud-personal.com"
  app-domain = "app.${local.domain}"

  # This is used to get the list of NS records created by the route53 hosted zone
  ns_records = flatten([
    for record in data.aws_route53_records.fetch-records.resource_record_sets : [
      for rr in record.resource_records : rr.value
    ] if record.type == "NS"
  ])
}

data "aws_route53_records" "fetch-records" {
    zone_id = aws_route53_zone.app.zone_id
}

output "r53_records" {
  value = local.ns_records
}

