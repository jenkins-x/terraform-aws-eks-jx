resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers"

  users = [
    aws_iam_user.alice.name,
    aws_iam_user.bob.name,
  ]

  group = aws_iam_group.developers.name
}

resource "aws_iam_group_policy" "developers" {
  name  = "developers"
  group = aws_iam_group.developers.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
