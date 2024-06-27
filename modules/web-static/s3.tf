resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = var.domain_name
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket_static.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.s3_bucket_static.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
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