#!/bin/sh

set -e
set -u

echo "linting terraform"

terraform init
terraform version
terraform validate

