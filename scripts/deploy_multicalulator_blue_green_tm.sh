#!/bin/bash

get_release_version () {
    DEPLOY_NAMESPACE=$1-$KUBERNETES_NAMESPACE
    RELEASE=$1-calculator
    echo -e "checking release $1 in $DEPLOY_NAMESPACE ..."
    helm list -n $DEPLOY_NAMESPACE -o table
    DEPLOYMENT=$(helm list -n $DEPLOY_NAMESPACE -o json | jq -r)
    VERSION="0"
    if [ "$DEPLOYMENT" == "[]" ]; then 
        echo -e "Found no release for $1"
        VERSION="0"
    else 
        echo "Found $DEPLOYMENT"
        STATUS=$(helm list -n $DEPLOY_NAMESPACE -o json | jq -r ".[0].status")
        echo -e "deployment status for $1 is $STATUS"
        if [ "$STATUS" == "deployed" ]; then 
            VERSION=$(helm list -n $DEPLOY_NAMESPACE -o json | jq -r ".[0].app_version" | cut -d. -f3)
            echo -e "deployment version for $1 is $VERSION"
        fi
    fi 
}

check_canary_slot () {
    DEPLOY_NAMESPACE=$1-$KUBERNETES_NAMESPACE
    RELEASE=$1-calculator
    echo -e "checking release $1 in $DEPLOY_NAMESPACE ..."
    #helm get values $RELEASE -n $DEPLOY_NAMESPACE -o table
    CANARY=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.canary')
    if [ "$CANARY" == "true" ]; then 
        CANARY_SLOT=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.slot')
        echo -e "Found $SLOT canary release in $1"
        echo "Canary $CANARY_SLOT will be deleted"
        helm delete $RELEASE --namespace $DEPLOY_NAMESPACE
        sleep 10
    else 
        echo -e "Found no canary release in $1"
    fi 
}

echo "Starting release"
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
KUBERNETES_NAMESPACE=$(az keyvault secret show --name "phoenix-namespace" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_NAME=$(az keyvault secret show --name "aks-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_GROUP=$(az keyvault secret show --name "aks-group" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_NAME=$(az keyvault secret show --name "tfm-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)

echo "Authenticating with azure container registry..."
az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
az acr helm repo add
helm repo update
#helm search repo -l $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary

echo "Pulling kube-config for $AKS_NAME in $AKS_GROUP"
az aks get-credentials --resource-group=$AKS_GROUP --name=$AKS_NAME

check_canary_slot "blue"
check_canary_slot "green"

BLUE_VERSION=0
GREEN_VERSION=0
get_release_version "blue"
BLUE_VERSION=$VERSION

get_release_version "green"
GREEN_VERSION=$VERSION

echo "Green is $GREEN_VERSION"
echo "Blue is $BLUE_VERSION"

if [ "$GREEN_VERSION" -gt "$BLUE_VERSION" ]; then 
    echo "Green is higher than blue - deploying blue"
    SLOT="blue"
else
    echo "Blue is higher than green - deploying green"
    SLOT="green"
fi

if [ "$GREEN_VERSION" == "0" ]; then 
if [ "$BLUE_VERSION" == "0" ]; then 
    NOCANARY="true"
fi
fi

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

NODE_GROUP=$(az aks show --resource-group $AKS_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
IP_RESOURCE_ID=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query id -o tsv)
DNS_LABEL=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.domainNameLabel -o tsv)
DNS=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.fqdn -o tsv)
IP=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query ipAddress -o tsv)

WEIGHT=1
if [ "$NOCANARY" == "true" ]; then 
    WEIGHT=100
    helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --set canary=false --wait --timeout 60s
else
    helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --set canary=true --wait --timeout 60s
fi

EXISTS=$(az network traffic-manager endpoint show --name $SLOT -g $AKS_GROUP --profile-name $TFM_NAME --type azureEndpoints --query name -o tsv)

if [ "$EXISTS" == $SLOT ]; then 
    az network traffic-manager endpoint update -g $AKS_GROUP --profile-name $TFM_NAME \
    -n $SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight $WEIGHT --custom-headers host=$DNS
else
    az network traffic-manager endpoint create -g $AKS_GROUP --profile-name $TFM_NAME \
    -n $SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight $WEIGHT --custom-headers host=$DNS
fi

echo "check canary under $DNS"
echo "done"
# echo $("curl -s -H "canary: never" -H "Host: $INGRESS_FQDN" http://$INGRESS_FQDN/ping")
# echo $('curl -s -H "canary: always" -H "Host: $INGRESS_FQDN" http://$INGRESS_FQDN/ping')

