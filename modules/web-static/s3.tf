resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = var.domain_name
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.s3_bucket_static.bucket

  index_document {
    suffix = var.default_page
  }

  error_document {
    key = var.default_page
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