# Performing blue/green deployments

```

AZURE_KEYVAULT_NAME=dzphix-461-vault

REDIS_HOST=$(az keyvault secret show --name "redis-host" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
REDIS_AUTH=$(az keyvault secret show --name "redis-access" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
APPINSIGHTS_KEY=$(az keyvault secret show --name "appinsights-key" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
INGRESS_FQDN=$(az keyvault secret show --name "phoenix-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
APPGW_FQDN=$(az keyvault secret show --name "appgw-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
KUBERNETES_NAMESPACE=$(az keyvault secret show --name "phoenix-namespace" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_NAME=$(az keyvault secret show --name "aks-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_GROUP=$(az keyvault secret show --name "aks-group" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)


```

## Using Nginx

```
SLOT="green"
BUILD_BUILDNUMBER="latest"
AZURE_CONTAINER_REGISTRY_NAME="."
AZURE_CONTAINER_REGISTRY_URL="denniszielke"

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$APPGW_FQDN --wait --timeout 60s

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
APPGW_FQDN=20.50.173.182.xip.io

DEPLOY_NAMESPACE=$SLOT-$KUBERNETES_NAMESPACE
RELEASE=$SLOT-calculator
kubectl create ns $DEPLOY_NAMESPACE

helm upgrade $RELEASE $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary --namespace $DEPLOY_NAMESPACE --install --set replicaCount=4 --set image.frontendTag=$BUILD_BUILDNUMBER --set image.backendTag=$BUILD_BUILDNUMBER --set image.repository=$AZURE_CONTAINER_REGISTRY_URL --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set slot=$SLOT --set ingress.host=$APPGW_FQDN --set ingress.class=azure/application-gateway --set ingress.canary=true  --wait --timeout 60s


```

## Using TrafficManager