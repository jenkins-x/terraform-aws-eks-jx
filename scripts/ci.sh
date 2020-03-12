#!/bin/bash

set -e
set -u

CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
VARS="-var cluster_name=${CLUSTER_NAME} -var region=us-east-1 -var account_id=${ACCOUNT_ID} -var vault_user=${VAULT_USER} -var vpc_name=${CLUSTER_NAME}-vpc -var create_vault_resources=true"

function cleanup()
{
	echo "Cleanup..."
	terraform destroy $VARS -auto-approve
}

trap cleanup EXIT

echo "Initializing modules..."
terraform init

echo "Generating Plan..."
PLAN=$(terraform plan $VARS -no-color)

#if [[ ! -z ${PULL_NUMBER:-} ]]; then
#	echo "Logging Plan..."
# 	jx step pr comment --code --comment="${PLAN}"
#else
#	echo "Not commenting the PR as we are not running in a pipeline"
#fi

echo "Creating cluster ${CLUSTER_NAME}"

echo "Applying Terraform..."
terraform apply $VARS -auto-approve

#if [[ ! -z ${PULL_NUMBER:-} ]]; then
#	echo "Commenting the resulting jx-requirements.yml"
#	JX_REQUIREMENTS=$(cat jx-requirements.yaml)
#	jx step pr comment --code --comment="${JX_REQUIREMENTS}"
#else
#	echo "Not commenting the PR as we are not running in a pipeline"
#fi

