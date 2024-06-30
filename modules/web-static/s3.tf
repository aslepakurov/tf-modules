resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = var.domain_name
  force_destroy = false

  tags = var.tags
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

#resource "aws_s3_bucket_policy" "this" {
#  bucket = aws_s3_bucket.s3_bucket_static.id
#
#  policy = jsonencode({
#    Version   = "2012-10-17"
#    Id        = "AllowGetObjects"
#    Statement = [
#      {
#        Sid       = "AllowPublic"
#        Effect    = "Allow"
#        Principal = "*"
#        Action    = "s3:GetObject"
#        Resource  = "${aws_s3_bucket.s3_bucket_static.arn}/**"
#      }
#    ]
#  })
#}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.s3_bucket_static.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "AllowGetObjects"
    Statement = [
      {
        "Sid"       = "PublicReadGetObject",
        "Effect"    = "Deny",
        "Principal" = "*",
        "Action"    = "s3:GetObject",
        "Resource"  = "${aws_s3_bucket.s3_bucket_static.arn}/**",
        "Condition" = {
          "NotIpAddress" = {
            "aws:SourceIp" = [
              "173.245.48.0/20",
              "103.21.244.0/22",
              "103.22.200.0/22",
              "103.31.4.0/22",
              "141.101.64.0/18",
              "108.162.192.0/18",
              "190.93.240.0/20",
              "188.114.96.0/20",
              "197.234.240.0/22",
              "198.41.128.0/17",
              "162.158.0.0/15",
              "104.16.0.0/13",
              "104.24.0.0/14",
              "172.64.0.0/13",
              "131.0.72.0/22",
              "2400:cb00::/32",
              "2606:4700::/32",
              "2803:f800::/32",
              "2405:b500::/32",
              "2405:8100::/32",
              "2a06:98c0::/29",
              "2c0f:f248::/32"
            ]
          }
        }
      }
    ]
  })
}