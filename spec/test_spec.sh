Describe "AWS"
  s3() {
    aws s3 ls $1
  }
  iam_role_name() {
    aws iam get-role --role-name=$(terraform output -json $1 | jq '.this_iam_role_name' | tr -d '"') | jq '.Role.RoleName'
  }
  sa() {
      kubectl get serviceaccounts $1 -n $2 -o json | jq '.metadata.annotations["eks.amazonaws.com/role-arn"]'
  }
  Describe "IAM"
    It "The Cert Manager IAM Role has been created"
      When call iam_role_name cert_manager_iam_role
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role-cert_manager-
    End
    It "The Tekton Bot IAM Role has been created"
      When call iam_role_name tekton_bot_iam_role 
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role1-tekton-bot-
    End
    It "The Cm CAInjector IAM Role has been created"
      When call iam_role_name cm_cainjector_iam_role 
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role-cm_cainjector-
    End
    It "The External DNS IAM Role has been created"
      When call iam_role_name external_dns_iam_role 
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role-external_dns-
    End
    It "The ControllerBuild IAM Role has been created"
      When call iam_role_name controllerbuild_iam_role 
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role-ctrlb-
    End
    It "The JX UI IAM Role has been created"
      When call iam_role_name jxui_iam_role 
      The output should include tf-$(terraform output cluster_name)-iamserviceaccount-Role-jxui-
    End
  End
  Describe "Service Accounts"
    It "The Tekton Bot Service Account contains the IRSA annotation with the correct role"
      When call sa tekton-bot jx
      The output should include $(terraform output -json tekton_bot_iam_role | jq '.this_iam_role_arn')
    End
    It "The cm-cainjector Service Account contains the IRSA annotation with the correct role"
      When call sa cm-cainjector cert-manager 
      The output should include $(terraform output -json cm_cainjector_iam_role | jq '.this_iam_role_arn')
    End
    It "The cm-cert-manager Service Account contains the IRSA annotation with the correct role"
      When call sa cm-cert-manager cert-manager 
      The output should include $(terraform output -json cert_manager_iam_role | jq '.this_iam_role_arn')
    End
    It "The jenkins-x-controllerbuild Service Account contains the IRSA annotation with the correct role"
      When call sa jenkins-x-controllerbuild jx 
      The output should include $(terraform output -json controllerbuild_iam_role | jq '.this_iam_role_arn')
    End
    It "The jxui Service Account contains the IRSA annotation with the correct role"
      When call sa jxui jx 
      The output should include $(terraform output -json jxui_iam_role | jq '.this_iam_role_arn')
    End
    It "The exdns-external-dns Service Account contains the IRSA annotation with the correct role"
      When call sa exdns-external-dns jx 
      The output should include $(terraform output -json external_dns_iam_role | jq '.this_iam_role_arn')
    End
  End
  Describe "Storage"
    It "The Logs bucket should be created"
      When call s3 $(terraform output lts_logs_bucket)
      The output should not include NoSuchBucket
    End
    It "The Reports bucket should be created"
      When call s3 $(terraform output lts_reports_bucket)
      The output should not include NoSuchBucket
    End
    It "The Repository bucket should be created"
      When call s3 $(terraform output lts_repository_bucket)
      The output should not include NoSuchBucket
    End
  End
  Describe "Vault"
    It "The Vault S3 Bucket should be created"
      When call s3 $(terraform output vault_unseal_bucket)
      The output should not include NoSuchBucket
    End
    It "The DynamoDB Table should be created"
      When call aws dynamodb describe-table --table-name=$(terraform output vault_dynamodb_table)
      The output should not include ResourceNotFoundException
    End
    It "The KMS Key should be created"
      When call aws kms describe-key --key-id=$(terraform output vault_kms_unseal)
      The output should not include NotFoundException
    End
  End
End