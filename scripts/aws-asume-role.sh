#!/usr/bin/env sh
#
# Creating and exporting temporary security credentials by assuming a specified role.
# It also assumes that MFA authentication is enabled and MFA devide id as well as current
# valid token are provided.
#
# This script needs to be evaluated into the current terminal session to take effect:
#
# eval $(./aws-asume-role.sh <role-arn> <mfa-serial> <mfa-code>)

# exit when any command fails
set -e

if [ $# -ne 3 ]; then
    echo "Usage 'eval \$($0 <role-arn> <mfa-serial> <mfa-code>)'" >&2
    exit 1
fi

temp_credentials=$(mktemp)
trap "rm -f ${temp_credentials}" EXIT

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_TOKEN_EXPIRATION

aws sts assume-role --role-arn $1 --role-session-name AWSCLI-Session --serial-number $2 --token-code $3 --duration-seconds 3600 > ${temp_credentials}

acess_key=$(jq -r .Credentials.AccessKeyId ${temp_credentials})
secret_access_key=$(jq -r .Credentials.SecretAccessKey ${temp_credentials})
session_token=$(jq -r .Credentials.SessionToken ${temp_credentials})
token_expiration=$(jq -r .Credentials.Expiration ${temp_credentials})

echo export AWS_ACCESS_KEY_ID=${acess_key}
echo export AWS_SECRET_ACCESS_KEY=${secret_access_key}
echo export AWS_SESSION_TOKEN=${session_token}
echo export AWS_TOKEN_EXPIRATION=${token_expiration}
