resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = var.domain_name
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_acl" "admin_site_acl" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.s3_bucket_static.bucket

  index_document {
    suffix = var.default_page
  }

  error_document {
    key = var.error_page
  }
}