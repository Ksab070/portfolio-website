# Create the R53 domain 
resource "aws_route53_zone" "app" {
  name = local.app-domain
  tags = merge(local.aws_tags, local.environment)
}

# Create the NS record for r53 subdomain delegation in Cloudflare
resource "cloudflare_dns_record" "ns-records-r53" {
  comment  = "NS record for r53 subdomain delegation"
  name     = "app"
  zone_id  = local.zone_id
  type     = "NS"
  ttl      = 1
  for_each = toset(local.ns_records)
  content  = each.value
  proxied  = false
}

# Request the ACM certificate
resource "aws_acm_certificate" "cert-for-app" {
  domain_name       = local.app-domain
  validation_method = "DNS"
  tags              = merge(local.aws_tags, local.environment)
}

# Create a r53 record for certificate validation
resource "aws_route53_record" "record-for-acm-validation" {
  zone_id = aws_route53_zone.app.zone_id
  type    = "CNAME"
  name    = tolist(aws_acm_certificate.cert-for-app.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.cert-for-app.domain_validation_options)[0].resource_record_value]
  ttl     = 1
}

# Manually trigger the validation for the aws certificate
resource "aws_acm_certificate_validation" "validation-for-cert" {
  certificate_arn = aws_acm_certificate.cert-for-app.arn
}


