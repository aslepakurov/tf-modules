resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = var.domain_name
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "admin_site_acl" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  acl = "public-read"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "AllowGetObjects"
    Statement = [
      {
        Sid       = "AllowPublic"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket_static.arn}/**"
      }
    ]
  })
}