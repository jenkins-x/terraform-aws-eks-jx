resource "aws_iam_user" "alice" {
  name = "alice"
}

resource "aws_iam_access_key" "alice" {
  user = aws_iam_user.alice.name
}

output "alice_aws_iam_user_arn" {
  value       = aws_iam_user.alice.arn
  description = "IAM ARN for alice"
}

output "alice_aws_access_key_id" {
  value       = aws_iam_access_key.alice.id
  description = "IAM Access Key ID for alice"
}

output "alice_aws_secret_access_key" {
  value       = aws_iam_access_key.alice.secret
  description = "IAM Secret Access Key for alice"
}


