# Use terraform to deploy all resources

1. prepare terraform execution

navigate to the terraform folder and ensure that all variables have been correctly configured in `variables.tf`
```
cd terraform
```

1. Create a sp for terraform
You need a service principal for Kubernetes to use - if you do not have, use the following command to creat one, get a secret and your azure tenant id and subscription id by running the following azure cli commands:

```
DEPLOYMENT_NAME=dphoenix

SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --role="Contributor" --name $DEPLOYMENT_NAME -o json | jq -r '.appId')
SERVICE_PRINCIPAL_SECRET=$(az ad app credential reset --id $SERVICE_PRINCIPAL_ID -o json | jq '.password' -r)
SERVICE_PRINCIPAL_OBJECTID=$(az ad sp show --id $SERVICE_PRINCIPAL_ID -o json | jq '.objectId' -r)
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "Your client_id should be $SERVICE_PRINCIPAL_ID"
echo "Your client_secret should be $SERVICE_PRINCIPAL_SECRET"
echo "Your tenant_id should be $AZURE_TENANT_ID"
echo "Your subscription_id should be $AZURE_SUBSCRIPTION_ID"
```

1. Your can replace these values in the variable file by running the following
```
sed -e "s/CLIENT_ID_PLACEHOLDER/$SERVICE_PRINCIPAL_ID/ ; s/CLIENT_SECRET_PLACEHOLDER/$SERVICE_PRINCIPAL_SECRET/ ; s/CLIENT_OBJECTID_PLACEHOLDER/$SERVICE_PRINCIPAL_OBJECTID/ ; s/TENANT_ID_PLACEHOLDER/$AZURE_TENANT_ID/ ; s/DEPLOYMENT_NAME/$DEPLOYMENT_NAME/ ; s/SUBSCRIPTION_ID_PLACEHOLDER/$AZURE_SUBSCRIPTION_ID/" variables.tf.template > variables_mod.tf
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
- Permission assignments on ACR, Keyvault (your terratorm app needs owner permissions on the subscription for that)
- Nginx Ingress Controller in AKS

1. trigger the deployment
apply the execution plan
```
terraform apply out.plan
```

1. Assign your azure devops service principals in the service connection to your azure keyvauls
```
az keyvault list --query '[].{Id:id}' -o tsv
```

open up all your keyvauls in a browser
```
for f in $(az keyvault list --query '[].{Id:id}' -o tsv); do
  open "https://portal.azure.com/#resource$f/access_policies"
done
```

1. optionally you can create another environment using the following process:

```
echo "deleting existing terraform state"
rm -rf .terraform
rm terraform.tfstate
rm terraform.tfstate.backup
rm out.plan

echo "retrieving existing azure container registry"
ACR_RG_ID=$(az group show -n $DEPLOYMENT_NAME --query id -o tsv)
ACR_ID=$(az acr list -g $DEPLOYMENT_NAME --query '[0].id' -o tsv)
ACR_PM_ID=$(az role assignment list --scope $ACR_ID --assignee $SERVICE_PRINCIPAL_OBJECTID --query '[0].id' -o tsv)

terraform init
echo "importing existing azure container registry"
terraform import azurerm_resource_group.acrrg $ACR_RG_ID
terraform import azurerm_container_registry.aksacr $ACR_ID
terraform import azurerm_role_assignment.aksacrrole $ACR_PM_ID

echo "redeploying"
terraform plan -out out.plan
terraform apply out.plan
```


