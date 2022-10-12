locals {
  mime_types = {
    html  = "text/html"
  }
  tags = {
    Name = "Terraform S3"
  }
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket = var.s3_bucket_name
  tags = local.tags
}

resource "aws_s3_bucket_acl" "terraform_s3" {
  bucket = aws_s3_bucket.terraform_s3.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "terraform_s3" {
  bucket = var.s3_bucket_name
  policy = templatefile("s3_static_policy.json", { bucket = var.s3_bucket_name })
}

resource "aws_s3_bucket_website_configuration" "terraform_s3" {
  bucket = aws_s3_bucket.terraform_s3.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "object" {
  for_each = fileset(path.module, "s3/s3-static/**/*")
  bucket = aws_s3_bucket.terraform_s3.id
  key    = replace(each.value, "s3/s3-static", "")
  source = each.value
  etag         = filemd5(each.value)
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}