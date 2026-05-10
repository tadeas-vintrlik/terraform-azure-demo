# Terraform Azure Demo

Exploration of IaC Azure setup using Terraform.

## Key Architecture Points

 - **State Management**: remote backend in Azure Blob Storage with versioning and locks to prevent accidental deletion
- **Security**: no long-lived secrets required uses Workload Identity Federation (with OIDC), least-privelege RBAC (this is at the cost of some automation convenience and a bit more involved initial manual setup is required).
- **Automation**: continuous and automated deployment using GitHub Actions

## Setup

It requires some initial manual setup to solve the Chicken and Egg problem with Terraform state stored in cloud:

1. Local setup

- Clone the repository
- in `bootstrap/providers.tf` comment out the `backend "azurerm"` block; this allows terraform to use local state for the initial run
- authenticate with the azure cli `az login`
- deploy the boostrap infrastructure for storing the state:

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

2. Identity and permissions

- create a service principal with federated credentials for github actions (see resources below for exact steps)
- assign roles:
	- Subscription Scope: grant `Contributor` to the Service Principal
	- Resource Group (`rg-tfstate`) Scope: grant both yourself and the service principal `Storage Blob Data Contributor`
	- Note: RBAC propagation can take up to a minute

3. State Migration

- uncomment the `backend "azurerm"` block in `providers.tf`
- run the migration with the following snippet:

```bash
SA_NAME=$(az storage account list --resource-group rg-tfstate --query "[0].name" -o tsv)
terraform init -migrate-state \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=$SA_NAME" \
  -backend-config="container_name=tfstate"
```

4. GitHub Action Configuration

- add the following secrets to your GitHub repository under Github Action Secrets:
  - `AZURE_CLIENT_ID`: The Application ID of your Service Principal.
  - `AZURE_TENANT_ID`: Your Azure AD Tenant ID.
  - `AZURE_SUBSCRIPTION_ID`: Your target Subscription ID.

## Resources

- intro to Terraform with Azure: https://developer.hashicorp.com/terraform/tutorials/azure-get-started
- setup Workload Identity Federation with OIDC: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect
- setup GitHub Actions for Terraform: https://learn.microsoft.com/en-us/devops/deliver/iac-github-actions
- official GitHub Actions for Terraform example: https://github.com/Azure-Samples/terraform-github-actions/tree/main
