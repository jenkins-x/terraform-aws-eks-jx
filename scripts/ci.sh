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

echo "Installing aws-iam-authenticator"
# Install aws-iam-authenticator to be able to connect to the cluster
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# Checking installation
aws-iam-authenticator help


echo "Initializing modules..."
terraform init

echo "Generating Plan..."
PLAN=$(terraform plan $VARS -no-color)

echo "Creating cluster ${CLUSTER_NAME}"

echo "Applying Terraform..."
terraform apply $VARS -auto-approve

echo "Reattempting Terraform Apply to make sure it works - Actual solution: WIP"
terraform apply $VARS -auto-approve

echo "Installing shellspec"
pushd /var/tmp
git clone https://github.com/shellspec/shellspec.git
export PATH=/var/tmp/shellspec/bin:${PATH}
popd

make test
