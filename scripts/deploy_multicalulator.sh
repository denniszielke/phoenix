#!/bin/bash
echo "Starting release"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "SYSTEM_HOSTTYPE is $SYSTEM_HOSTTYPE"
echo "Build Id is $BUILD_BUILDNUMBER and $BUILD_ID"
echo "Azure Container Registry is $AZURE_CONTAINER_REGISTRY_NAME"
AZURE_CONTAINER_REGISTRY_URL=$AZURE_CONTAINER_REGISTRY_NAME.azurecr.io
echo "Azure Container Registry Url is $AZURE_CONTAINER_REGISTRY_URL"
echo "Azure KeyVault is $AZURE_KEYVAULT_NAME"


REDIS_HOST=$(az keyvault secret show --name "redis-host" --vault-name $AZURE_KEYVAULT_NAME)
REDIS_AUTH=$(az keyvault secret show --name "redis-access" --vault-name $AZURE_KEYVAULT_NAME)
APPINSIGHTS_KEY=$(az keyvault secret show --name "appinsights-key" --vault-name $AZURE_KEYVAULT_NAME)
INGRESS_FQDN=$(az keyvault secret show --name "phoenix-fqdn" --vault-name $AZURE_KEYVAULT_NAME)


echo "Redis Host $REDIS_HOST"
echo "Redis Key $REDIS_AUTH"
echo "Appinsights $APPINSIGHTS_KEY"

az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
az acr helm list --name $AZURE_CONTAINER_REGISTRY_NAME

helm search repo -l $AZURE_CONTAINER_REGISTRY_NAME/multicalculator