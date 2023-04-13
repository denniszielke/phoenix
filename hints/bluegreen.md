# Performing blue/green deployments

```

AZURE_KEYVAULT_NAME=dzphix-520-vault

REDIS_HOST=$(az keyvault secret show --name "redis-host" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
REDIS_AUTH=$(az keyvault secret show --name "redis-access" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
APPINSIGHTS_KEY=$(az keyvault secret show --name "appinsights-key" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
INGRESS_FQDN=$(az keyvault secret show --name "phoenix-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
APPGW_FQDN=$(az keyvault secret show --name "appgw-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
KUBERNETES_NAMESPACE=$(az keyvault secret show --name "phoenix-namespace" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_NAME=$(az keyvault secret show --name "aks-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_GROUP=$(az keyvault secret show --name "aks-group" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
ACR_NAME=$(az keyvault secret show --name "acr-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_BLUE_IP=$(az keyvault secret show --name "tfm-blue-ip" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_GREEN_IP=$(az keyvault secret show --name "tfm-green-ip" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
TFM_NAME=$(az keyvault secret show --name "tfm-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
```

## Using Nginx

```
SLOT="blue"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$INGRESS_FQDN --wait --timeout 60s

SLOT="green"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"
APPGW_FQDN=20.50.173.182.nip.io

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE


helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$INGRESS_FQDN --wait --timeout 60s

```

## Using AppGateway
```
SLOT="blue"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"
APPGW_FQDN=dzphoenix.westeurope.cloudapp.azure.com

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$APPGW_FQDN --set ingress.class=azure/application-gateway --wait --timeout 60s

SLOT="green"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"
APPGW_FQDN=20.50.173.182.nip.io

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$APPGW_FQDN --set ingress.class=azure/application-gateway --set canary=true  --wait --timeout 60s


```

## Using TrafficManager


```
SLOT="blue"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"
DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

NODE_GROUP=$(az aks show --resource-group $AKS_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
IP_RESOURCE_ID=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query id -o tsv)
DNS_LABEL=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.domainNameLabel -o tsv)
DNS=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.fqdn -o tsv)
IP=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query ipAddress -o tsv)

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --dry-run --debug --wait --timeout 60s

az network traffic-manager endpoint update -g $AKS_GROUP --profile-name $TFM_NAME --endpoint-status Enabled \
    -n $SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight 100 --custom-headers host=$DNS

SLOT="green"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"
DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

NODE_GROUP=$(az aks show --resource-group $AKS_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
IP_RESOURCE_ID=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query id -o tsv)
DNS_LABEL=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.domainNameLabel -o tsv)
DNS=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query dnsSettings.fqdn -o tsv)
IP=$(az network public-ip show -g $NODE_GROUP -n tfm-$SLOT --query ipAddress -o tsv)

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.enabled=false --set service.type=LoadBalancer --set service.dns=$DNS_LABEL --set service.ip=$IP --wait --timeout 60s

EXISTS=$(az network traffic-manager endpoint show --name $SLOT -g $AKS_GROUP --profile-name $TFM_NAME --type azureEndpoints --query name -o tsv)

if [ "$EXISTS" == $SLOT ]; then 
    az network traffic-manager endpoint update -g $AKS_GROUP --profile-name $TFM_NAME \
    -n $SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight 100 --custom-headers host=$DNS
else
    az network traffic-manager endpoint create -g $AKS_GROUP --profile-name $TFM_NAME \
    -n $SLOT --type azureEndpoints --target-resource-id $IP_RESOURCE_ID --endpoint-status enabled \
    --weight 100 --custom-headers host=$DNS
fi

az network traffic-manager endpoint delete -g $AKS_GROUP --profile-name $TFM_NAME -n $SLOT --type azureEndpoints

```