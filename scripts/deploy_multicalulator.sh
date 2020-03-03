#!/bin/bash
echo "Starting release"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "SYSTEM_HOSTTYPE is $SYSTEM_HOSTTYPE"
echo "Build Id is $BUILD_BUILDNUMBER and $BUILD_BUILDID"
echo "Azure Container Registry is $AZURE_CONTAINER_REGISTRY_NAME"
AZURE_CONTAINER_REGISTRY_URL=$AZURE_CONTAINER_REGISTRY_NAME.azurecr.io
echo "Azure Container Registry Url is $AZURE_CONTAINER_REGISTRY_URL"
echo "Azure KeyVault is $AZURE_KEYVAULT_NAME"


REDIS_HOST=$(az keyvault secret show --name "redis-host" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
REDIS_AUTH=$(az keyvault secret show --name "redis-access" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
APPINSIGHTS_KEY=$(az keyvault secret show --name "appinsights-key" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
INGRESS_FQDN=$(az keyvault secret show --name "phoenix-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)


echo "Redis Host $REDIS_HOST"
echo "Redis Key $REDIS_AUTH"
echo "Appinsights $APPINSIGHTS_KEY"
echo "Ingress $INGRESS_FQDN"

az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
az acr helm repo add
helm repo update
helm search repo -l $AZURE_CONTAINER_REGISTRY_NAME/multicalculator

#helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install  --set replicaCount=4  --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH