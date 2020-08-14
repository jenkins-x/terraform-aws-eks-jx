module "eks-jx" {
  source = "jenkins-x/eks-jx/aws"
  map_users = [
    {
      userarn  = aws_iam_user.alice.arn
      username = aws_iam_user.alice.name
      groups   = ["system:masters"]
    },
    {
      userarn  = aws_iam_user.bob.arn
      username = aws_iam_user.bob.name
      groups   = ["system:masters"]
    }
  ]
}
