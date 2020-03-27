#!/bin/bash

set -e
set -u

CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$( echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
VARS="-var cluster_name=${CLUSTER_NAME} -var region=us-east-1 -var vault_user=${VAULT_USER} -var vpc_name=${CLUSTER_NAME}-vpc"

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

echo "Installing the AWS CLI"
# Install the AWS CLI to run commands in tests
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Checking AWS Installation
aws --version

echo "Initializing modules..."
terraform init

echo "Creating cluster ${CLUSTER_NAME}"

echo "Applying Terraform..."
terraform apply $VARS -auto-approve

echo "Installing shellspec"
pushd /var/tmp
git clone https://github.com/shellspec/shellspec.git
export PATH=/var/tmp/shellspec/bin:${PATH}
popd

make test
