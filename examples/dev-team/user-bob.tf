resource "aws_iam_user" "bob" {
  name = "bob"
}

resource "aws_iam_access_key" "bob" {
  user = aws_iam_user.bob.name
}

output "bob_aws_iam_user_arn" {
  value       = aws_iam_user.bob.arn
  description = "IAM ARN for bob"
}

output "bob_aws_access_key_id" {
  value       = aws_iam_access_key.bob.id
  description = "IAM Access Key ID for bob"
}

output "bob_aws_secret_access_key" {
  value       = aws_iam_access_key.bob.secret
  description = "IAM Secret Access Key for bob"
}


