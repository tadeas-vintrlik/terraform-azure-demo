#!/usr/bin/env bash
# Bootstrap the terraform setup. Create the storage for tfstate using azure cli.
# Requires to be logged into Azure CLI beforehand.

set -eu
set -x

export TF_VAR_current_ip="$(curl -s https://api.ipify.org)"

# Setup the terraform state storage in Azure
cd bootstrap
terraform init
terraform apply -auto-approve
SA_NAME="$(terraform output -raw storage_account_name)"
RG_NAME="$(terraform output -raw resource_group_name)"
SC_NAME="$(terraform output -raw storage_container_name)"

echo "Wait 60 seconds for IAM to propagate"
sleep 60

cd ../prod
terraform init \
  -backend-config="resource_group_name=$RG_NAME" \
  -backend-config="storage_account_name=$SA_NAME" \
  -backend-config="container_name=$SC_NAME" \
  -reconfigure
terraform apply -auto-approve
