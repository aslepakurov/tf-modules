resource "aws_iam_user" "iam_user" {
  name = var.iam_user_name
  path = var.iam_user_path
  tags = var.tags
}

resource "aws_iam_policy" "policy_files" {
  for_each = var.policy_files

  name   = each.key
  policy = file(each.value)
  tags   = var.tags
}

resource "aws_iam_user_policy_attachment" "user_policy_files" {
  for_each = aws_iam_policy.policy_files

  policy_arn = each.value.arn
  user       = aws_iam_user.iam_user.name
}