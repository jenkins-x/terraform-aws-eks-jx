
output "logs-jenkins-x" {
    value = aws_s3_bucket.logs-jenkins-x[0].id
}

output "reports-jenkins-x" {
    value = aws_s3_bucket.reports-jenkins-x[0].id
}

output "repository-jenkins-x" {
    value = aws_s3_bucket.repository-jenkins-x[0].id
}
