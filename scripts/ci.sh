#!/bin/bash

set -e
set -u

CLUSTER_NAME=tf-${BRANCH_NAME}-${BUILD_NUMBER}
CLUSTER_NAME=$(echo ${CLUSTER_NAME} | tr  '[:upper:]' '[:lower:]')
VAULT_USER=$(echo ${VAULT_USER} | tr -d '\n')

cat <<EOF > terraform.tfvars
cluster_name="${CLUSTER_NAME}"
region="us-east-1"
vault_user="${VAULT_USER}"
vpc_name="${CLUSTER_NAME}-vpc"
EOF

function cleanup()
{
	echo "Cleanup..."
	make destroy
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
unzip awscliv2.zip > /dev/null
./aws/install 

# Checking AWS Installation
aws --version

echo "Initializing modules..."
make init

echo "Creating cluster ${CLUSTER_NAME}"
make apply

echo "Running shellspec tests"
make test
