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
}

