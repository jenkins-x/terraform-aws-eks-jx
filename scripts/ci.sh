#!/bin/sh

set -e
set -u

# Checking AWS Installation
aws --version

#echo "Installing aws-iam-authenticator"
# Install aws-iam-authenticator to be able to connect to the cluster
#curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
#chmod +x ./aws-iam-authenticator
#mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
#echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# Checking installation
aws-iam-authenticator help

#echo "Installing the AWS CLI"
# Install the AWS CLI to run commands in tests
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#unzip awscliv2.zip > /dev/null
#./aws/install

echo "Running terratest"
TF_VAR_vault_user=$(echo ${VAULT_USER} | tr -d '\n') make test
