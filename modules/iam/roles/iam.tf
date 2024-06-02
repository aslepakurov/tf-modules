resource "aws_iam_role" "iam_role" {
  name        = var.iam_role_name
  description = var.iam_role_description

  assume_role_policy = file(var.assume_file)

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