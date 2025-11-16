terraform {
  backend "s3" {
    # Explicitly adding values here, since variables are not allowed in terraform backend configuration block
    bucket       = "prod-tfstate-crc"
    key          = "prod/CORE-tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}