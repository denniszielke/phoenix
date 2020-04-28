# Use terraform to deploy all resources

1. prepare terraform execution for the simple deployment

open up an shell.azure.com

```
git clone https://github.com/denniszielke/phoenix.git
cd phoenix/terraform/simple
code .
```

1. Create the service principals for AKS and Azure DevOps.
You need a service principal for your azure devops service connection that it can use to authenticate to your azure subscription.
You need a service principal for Kubernetes to use - if you do not have, use the following command to creat one, get a secret and your azure tenant id and subscription id by running the following azure cli commands:
Try to define a unique but short deployment name - it will be used to define  dns names

```
DEPLOYMENT_NAME=dztenix

AKS_SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --name $DEPLOYMENT_NAME-aks -o json | jq -r '.appId')
AZDO_SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --name $DEPLOYMENT_NAME-azdo -o json | jq -r '.appId')

AKS_SERVICE_PRINCIPAL_SECRET=$(az ad app credential reset --id $AKS_SERVICE_PRINCIPAL_ID -o json | jq '.password' -r)
AZDO_SERVICE_PRINCIPAL_SECRET=$(az ad app credential reset --id $AZDO_SERVICE_PRINCIPAL_ID -o json | jq '.password' -r)

AKS_SERVICE_PRINCIPAL_OBJECTID=$(az ad sp show --id $AKS_SERVICE_PRINCIPAL_ID -o json | jq '.objectId' -r)
AZDO_SERVICE_PRINCIPAL_OBJECTID=$(az ad sp show --id $AZDO_SERVICE_PRINCIPAL_ID -o json | jq '.objectId' -r)

AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_MYOWN_OBJECT_ID=$(az ad signed-in-user show --query objectId --output tsv)

echo -e "\n\n Remember these outputs:"
echo -e "Your Kubernetes service_principal_id should be \e[7m$AKS_SERVICE_PRINCIPAL_ID\e[0m"
echo -e "Your Kubernetes service_principal_secret should be \e[7m$AKS_SERVICE_PRINCIPAL_SECRET\e[0m"
echo -e "Your Azure DevOps service_principal_id should be \e[7m$AZDO_SERVICE_PRINCIPAL_ID\e[0m"
echo -e "Your Azure DevOps service_principal_secret should be \e[7m$AZDO_SERVICE_PRINCIPAL_SECRET\e[0m"
echo -e "Your Azure tenant_id should be \e[7m$AZURE_TENANT_ID\e[0m"
echo -e "Your Azure subscription_id should be \e[7m$AZURE_SUBSCRIPTION_ID\e[0m"
echo -e "Your Azure subscription_name should be \e[7m$AZURE_SUBSCRIPTION_NAME\e[0m"
echo -e "Your Azure DevOps Service Connection name should be \e[7mdefaultAzure\e[0m"
echo -e "\n\n"


echo -e "\n This is the private output in case you want to set them later:"
echo -e "AKS_SERVICE_PRINCIPAL_ID=$AKS_SERVICE_PRINCIPAL_ID"
echo -e "AZDO_SERVICE_PRINCIPAL_ID=$AZDO_SERVICE_PRINCIPAL_ID"
echo -e "AKS_SERVICE_PRINCIPAL_SECRET=$AKS_SERVICE_PRINCIPAL_SECRET"
echo -e "AZDO_SERVICE_PRINCIPAL_SECRET=$AZDO_SERVICE_PRINCIPAL_SECRET"
echo -e "AKS_SERVICE_PRINCIPAL_OBJECTID=$AKS_SERVICE_PRINCIPAL_OBJECTID"
echo -e "AZDO_SERVICE_PRINCIPAL_OBJECTID=$AZDO_SERVICE_PRINCIPAL_OBJECTID"
echo -e "AZURE_TENANT_ID=$AZURE_TENANT_ID"
echo -e "AZURE_SUBSCRIPTION_NAME=$AZURE_SUBSCRIPTION_NAME"
echo -e "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo -e "AZURE_MYOWN_OBJECT_ID=$AZURE_MYOWN_OBJECT_ID"
echo -e "\n"
```

1. Your can replace these values in the variable file by running the following
```
sed -e "s/SERVICE_PRINCIPAL_ID_PLACEHOLDER/$AKS_SERVICE_PRINCIPAL_ID/ ; s/SERVICE_PRINCIPAL_SECRET_PLACEHOLDER/$AKS_SERVICE_PRINCIPAL_SECRET/ ; s/SERVICE_PRINCIPAL_OBJECTID_PLACEHOLDER/$AKS_SERVICE_PRINCIPAL_OBJECTID/ ; s/AZDO_OBJECTID_PLACEHOLDER/$AZDO_SERVICE_PRINCIPAL_OBJECTID/ ; s/TENANT_ID_PLACEHOLDER/$AZURE_TENANT_ID/ ; s/DEPLOYMENT_NAME/$DEPLOYMENT_NAME/ ; s/SUBSCRIPTION_ID_PLACEHOLDER/$AZURE_SUBSCRIPTION_ID/ ; s/MYOBJECT_ID_PLACEHOLDER/$AZURE_MYOWN_OBJECT_ID/ " variables.tf.template > variables_mod.tf
```


1. initialize the terraform state
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
- Permission assignments on ACR, Keyvault (your azure devops service principals needs permissions on these resources for that)
- Nginx Ingress Controller in AKS
- Traffic Manager Profile

1. trigger the deployment
apply the execution plan
```
terraform apply out.plan
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
ACR_AKS_ID=$(az role assignment list --scope $ACR_ID --assignee $AKS_SERVICE_PRINCIPAL_OBJECTID --query '[0].id' -o tsv)
ACR_AZDO_ID=$(az role assignment list --scope $ACR_ID --assignee $AZDO_SERVICE_PRINCIPAL_OBJECTID --query '[0].id' -o tsv)
ATF_ID=$(az network traffic-manager profile list -g $DEPLOYMENT_NAME --query '[0].id' -o tsv)

terraform init
echo "importing existing azure container registry"
terraform import azurerm_resource_group.acrrg $ACR_RG_ID
terraform import azurerm_container_registry.aksacr $ACR_ID
terraform import azurerm_role_assignment.aksacrrole $ACR_AKS_ID
terraform import azurerm_role_assignment.azdoacrrole $ACR_AZDO_ID
terraform import azurerm_traffic_manager_profile.shared_traffic $ATF_ID

echo "redeploying"
terraform plan -out out.plan
terraform apply out.plan
```
