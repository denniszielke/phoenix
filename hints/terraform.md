# Use terraform to deploy all resources

0. Define variables
```
TERRAFORM_STORAGE_NAME=
SUBSCRIPTION_ID=
TERRAFORM_RG_NAME=terraform 
LOCATION=westeurope
```

1. Create a sp for terraform
You need a service principal that has permissions to create resources in your subscriptions - if you do not have one already you can create one

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}" --name "terraform_sp"
```

2. Create storage account for storing terraform state

```
az group create -n $TERRAFORM_RG_NAME -l $LOCATION

az storage account create --resource-group $TERRAFORM_RG_NAME --name $TERRAFORM_STORAGE_NAME --location $LOCATION --sku Standard_LRS

TERRAFORM_STORAGE_KEY=$(az storage account keys list --account-name $TERRAFORM_STORAGE_NAME --resource-group $TERRAFORM_RG_NAME --query "[0].value")

az storage container create -n tfstate --account-name $TERRAFORM_STORAGE_NAME --account-key $TERRAFORM_STORAGE_KEY
```

3. plan terraform execution and execute plan

navigate to the terraform folder and ensure that all variables have been correctly configured in `variables.tf`
```
cd terraform
```

initialize the terraform state storage account
```
./terraform init -backend-config="storage_account_name=$TERRAFORM_STORAGE_NAME" -backend-config="container_name=tfstate" -backend-config="access_key=$TERRAFORM_STORAGE_KEY" -backend-config="key=codelab.microsoft.tfstate" 
```

create an execution plan
```
./terraform plan -out out.plan
```

apply the execution plan
```
./terraform apply out.plan
```