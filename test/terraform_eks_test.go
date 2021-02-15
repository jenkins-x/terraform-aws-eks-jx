package test

import (
	"context"
	"log"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eks"
	"github.com/aws/aws-sdk-go-v2/service/iam"
	"github.com/aws/aws-sdk-go-v2/service/kms"
	aws2 "github.com/gruntwork-io/terratest/modules/aws"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformEksJX(t *testing.T) {
	t.Parallel()

	tfOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/jx3",
		NoColor:      true,
		Logger:       logger.Discard,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, tfOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, tfOptions)

	// Retrieve region from environment variable. There is a bug with the way region is propagated to submodules,
	// till that is fixed, it's better to pass the region as an environment variable
	region := os.Getenv("AWS_REGION")

	// Check if eks cluster was created
	clusterName := terraform.Output(t, tfOptions, "cluster_name")
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(region))
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}
	// testSession := session.Must(session.NewSession())
	eksClient := eks.NewFromConfig(cfg)
	_, err = eksClient.DescribeCluster(context.TODO(), &eks.DescribeClusterInput{
		Name: aws.String(clusterName),
	})
	assert.NoError(t, err)

	// Test for bucket creation
	LogsBucket := terraform.Output(t, tfOptions, "lts_logs_bucket")
	aws2.AssertS3BucketExists(t, region, LogsBucket)

	ReportsBucket := terraform.Output(t, tfOptions, "lts_reports_bucket")
	aws2.AssertS3BucketExists(t, region, ReportsBucket)

	RepositoryBucket := terraform.Output(t, tfOptions, "lts_repository_bucket")
	aws2.AssertS3BucketExists(t, region, RepositoryBucket)

	// IAM roles
	cmRole := terraform.Output(t, tfOptions, "cert_manager_iam_role")
	iamClient := iam.NewFromConfig(cfg)
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(cmRole),
	})
	assert.NoError(t, err)

	tektonRole := terraform.Output(t, tfOptions, "tekton_bot_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(tektonRole),
	})
	assert.NoError(t, err)

	exDNSRole := terraform.Output(t, tfOptions, "external_dns_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(exDNSRole),
	})
	assert.NoError(t, err)

	cmcaRole := terraform.Output(t, tfOptions, "cm_cainjector_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(cmcaRole),
	})
	assert.NoError(t, err)

	ctrlRole := terraform.Output(t, tfOptions, "controllerbuild_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(ctrlRole),
	})
	assert.NoError(t, err)

	asRole := terraform.Output(t, tfOptions, "cluster_autoscaler_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(asRole),
	})
	assert.NoError(t, err)

	pVizRole := terraform.Output(t, tfOptions, "pipeline_viz_iam_role")
	_, err = iamClient.GetRole(context.TODO(), &iam.GetRoleInput{
		RoleName: aws.String(pVizRole),
	})
	assert.NoError(t, err)

	// Vault
	vaultBucket := terraform.Output(t, tfOptions, "vault_unseal_bucket")
	aws2.AssertS3BucketExists(t, region, vaultBucket)

	vaultDynamoTable := terraform.Output(t, tfOptions, "vault_dynamodb_table")
	results := aws2.GetDynamoDBTable(t, region, vaultDynamoTable)
	assert.NotEmpty(t, results)

	vaultKMS := terraform.Output(t, tfOptions, "vault_kms_unseal")
	kmsClient := kms.NewFromConfig(cfg)
	_, err = kmsClient.DescribeKey(context.TODO(), &kms.DescribeKeyInput{KeyId: aws.String(vaultKMS)})
	assert.NoError(t, err)
}
