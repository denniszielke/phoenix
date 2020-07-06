#!/bin/bash
check_canary_slot () {
    DEPLOY_NAMESPACE=$1-$KUBERNETES_NAMESPACE
    RELEASE=$1-calculator
    echo -e "checking release $1 in $DEPLOY_NAMESPACE ..."
    
    CANARY=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.canary' -r)
    if [ "$CANARY" == "true" ]; then 
        CANARY_SLOT=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.slot' -r)
        if [ "$CANARY_SLOT" == "blue" ]; then 
            PRODUCTION_SLOT="green"
        elif [ "$CANARY_SLOT" == "green" ]; then
            PRODUCTION_SLOT="blue"
        fi
        echo -e "Found $CANARY_SLOT canary release in $1"
    else 
        echo -e "Found no canary release in $1"
    fi 
}

echo "Starting failure cleanup"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
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
KUBERNETES_NAMESPACE=$(az keyvault secret show --name "phoenix-namespace" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_NAME=$(az keyvault secret show --name "aks-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_GROUP=$(az keyvault secret show --name "aks-group" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_NAME=$(az keyvault secret show --name "tfm-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_BLUE_IP=$(az keyvault secret show --name "tfm-blue-ip" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_GREEN_IP=$(az keyvault secret show --name "tfm-green-ip" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)

echo "Authenticating with azure container registry..."
az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
az acr helm repo add
helm repo update
#helm search repo -l $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary

echo "Pulling kube-config for $AKS_NAME in $AKS_GROUP"
az aks get-credentials --resource-group=$AKS_GROUP --name=$AKS_NAME

CANARY_SLOT="none"
PRODUCTION_SLOT="none"

check_canary_slot "blue"
check_canary_slot "green"

if [ "$CANARY_SLOT" !=  "none" ]; then 
NODE_GROUP=$(az aks show --resource-group $AKS_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
IP_RESOURCE_ID=$(az network public-ip show -g $NODE_GROUP -n tfm-$CANARY_SLOT --query id -o tsv)
DNS_LABEL=$(az network public-ip show -g $NODE_GROUP -n tfm-$CANARY_SLOT --query dnsSettings.domainNameLabel -o tsv)
DNS=$(az network public-ip show -g $NODE_GROUP -n tfm-$CANARY_SLOT --query dnsSettings.fqdn -o tsv)
IP=$(az network public-ip show -g $NODE_GROUP -n tfm-$CANARY_SLOT --query ipAddress -o tsv)

echo "Canary $CANARY_SLOT will be promoted to production"
DEPLOY_NAMESPACE=$CANARY_SLOT-$KUBERNETES_NAMESPACE
RELEASE=$CANARY_SLOT-calculator
echo "running helm upgrade"
echo $("helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --wait --timeout 60s")
helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --set canary=false --wait --timeout 60s

if [ "$PRODUCTION_SLOT" !=  "none" ]; then 
echo "Production $PRODUCTION_SLOT will be deleted"
az network traffic-manager endpoint delete -g $AKS_GROUP --profile-name $TFM_NAME -n $PRODUCTION_SLOT --type azureEndpoints
sleep 10
DEPLOY_NAMESPACE=$PRODUCTION_SLOT-$KUBERNETES_NAMESPACE
RELEASE=$PRODUCTION_SLOT-calculator
helm delete $RELEASE --namespace $DEPLOY_NAMESPACE
fi

echo "Canary $CANARY_SLOT will be promoted to production"
az network traffic-manager endpoint update -g $AKS_GROUP --profile-name $TFM_NAME \
    -n $CANARY_SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight 100 --custom-headers host=$DNS

fi
