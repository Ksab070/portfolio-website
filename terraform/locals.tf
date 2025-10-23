locals {
    aws_tags = {
        "Terraform": "Yes"
    }

    environment = {
        "production": "Yes"
    }

    # This sets the front-end path for upload to s3 bucket
    frontend_files = fileset("${path.module}/../front-end", "**")
    
    s3_origin_id = "my-s3-origin"

    zone_id = "31b75f303b467246315ff1d5fe271fef"
    account_id = "1cdd8c65585d05850ca3bb2548e5c6e7"
}

