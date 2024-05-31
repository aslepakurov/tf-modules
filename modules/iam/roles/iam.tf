resource "aws_iam_role" "iam_role" {
  name        = var.iam_role_name
  description = var.iam_role_description

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = var.assume_role_principal
      },
    ]
  })

  max_session_duration = var.iam_role_max_session
  tags                 = var.tags
}

resource "aws_iam_policy" "policy_files" {
  for_each = var.policy_files
  name     = each.key
  policy   = file(each.value)
  tags     = var.tags
}

resource "aws_iam_role_policy_attachment" "role_policy_files" {
  for_each   = aws_iam_policy.policy_files
  policy_arn = each.value.arn
  role       = aws_iam_role.iam_role.name
}