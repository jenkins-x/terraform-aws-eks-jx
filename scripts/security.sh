#!/bin/sh

set -e
set -u

echo "terraform security check"

export TFSEC="tfsec"

# ensure we have curl
apk add curl

curl -L "https://github.com/tfsec/tfsec/releases/download/v0.37.3/tfsec-linux-amd64" > $TFSEC
chmod +x $TFSEC

$TFSEC --version

$TFSEC -e AWS002,AWS017
