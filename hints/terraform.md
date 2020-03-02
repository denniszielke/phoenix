# Use terraform to deploy all resources

1. prepare terraform execution

navigate to the terraform folder and ensure that all variables have been correctly configured in `variables.tf`
```
cd terraform
```

1. Create a sp for terraform
You need a service principal for Kubernetes to use - if you do not have, use the following command to creat one, get a secret and your azure tenant id and subscription id by running the following azure cli commands:

```
DEPLOYMENT_NAME=dzphoenix

SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --role="Contributor" --name $DEPLOYMENT_NAME -o json | jq -r '.appId')
SERVICE_PRINCIPAL_SECRET=$(az ad app credential reset --id $SERVICE_PRINCIPAL_ID -o json | jq '.password' -r)
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "Your client_id should be $SERVICE_PRINCIPAL_ID"
echo "Your client_secret should be $SERVICE_PRINCIPAL_SECRET"
echo "Your tenant_id should be $AZURE_TENANT_ID"
echo "Your subscription_id should be $AZURE_SUBSCRIPTION_ID"
```

1. Your can replace these values in the variable file by running the following
```
sed -e "s/CLIENT_ID_PLACEHOLDER/$SERVICE_PRINCIPAL_ID/ ; s/CLIENT_SECRET_PLACEHOLDER/$SERVICE_PRINCIPAL_SECRET/ ; s/TENANT_ID_PLACEHOLDER/$AZURE_TENANT_ID/ ; s/DEPLOYMENT_NAME/$DEPLOYMENT_NAME/ ; s/SUBSCRIPTION_ID_PLACEHOLDER/$AZURE_SUBSCRIPTION_ID/" variables.tf > variables_mod.tf
mv variables.tf variables.template
```


1. initialize the terraform state storage account
```
terraform init
```

1. create an execution plan and execute it
```
terraform plan -out out.plan
```

1. this will ensure the following deployment:
- Azure Resource Group
- Azure Virtual Network
- Azure Container Registry
- Application Insights
- Azure Cache for Redis
- Azure Kubernetes Cluster
- Azure Container Insights
- Azure KeyVault
- Variables for Azure Container Registry, Application Insights and Azure Redis inside the Azure KeyVault as secrets

1. trigger the deployment
apply the execution plan
```
terraform apply out.plan
```