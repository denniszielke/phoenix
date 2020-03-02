# Using Helm

## Installing helm
https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm (not required for azure shell) on your own machine: https://github.com/helm/helm#install

> We are using Helm 3 - if you have helm2 installed please check the version before and upgrade to helm3.

Find and install helm charts from https://hub.helm.sh/

## Create your own helm chart

1. Create helm chart manually and modify accordingly

```
helm create dummychart
```

1. Validate template
```
helm lint ./dummychart
```

1. Perform a dry run of an installation
```
helm upgrade dummyInstanceName ./dummychart --install --dry-run --debug
```

add helm stable repo to your helm instance
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com
```

Check the output

## Package your own helm chart
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos#add-a-chart-to-the-repository

Create a tar from my helm chart
```
helm package dummychart --version 1.0.0 --app-version 1.0.12
```

List the azure container registry and configure it
```
ACR_NAME=$( az acr list --query "[].{Name:name}" -o tsv )
az configure --defaults acr=$ACR_NAME
az acr helm repo add
```

Push your local helm chart to your acr
```
az acr helm push dummychart-1.0.0.tgz --force
```

helm search 
```
az acr helm list -o table
```

## Deploy the existing multicalculator 

1. Dry run the chart and override parameters
```
cd /phoenix/charts
APP_NS=calculator
APP_IN=calc1
kubectl create ns $APP_NS
helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install --dry-run --debug
```

You should see the dry run yaml output that would have been sent to Kubernetes

1. Now install the helm chart for real
```
helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install
```

1. verify
```
helm list -n $APP_NS
helm get values $APP_IN $APP_IN
```

1. Change config and perform an upgrade (change the backend image to to the go version and/or add application insights)
```
helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install
```

1. Change config and perform an upgrade (add application insights to your app)
```

APPINSIGHTS_KEY=
helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install  --set replicaCount=4  --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true
```

1. Check the values
```
helm get values $APP_IN $APP_IN
```

Examine the side car redis cache container and the performance impact.

## Add azure redis cache to your calculator

1. The performance might be better if you use an azure redis cache. Create a redis cache
```
az redis create --location $LOCATION --name myownredis --resource-group $KUBE_GROUP --sku Basic --enable-non-ssl-port
```

1. If you have a redis secret you can turn on the redis cache
```
REDIS_HOST=myownredis.redis.cache.windows.net
REDIS_AUTH=Idfsdfsd+Bs=
helm upgrade $APP_IN ./multicalculator --namespace $APP_NS --install  --set replicaCount=4  --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true
--set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH
```

1. You can introduce faults, delays and errors in the backend by using the following config:
```
helm upgrade $APP_IN multicalculator --install --set backendReplicaCount=3 --set frontendReplicaCount=3 --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set introduceRandomResponseLag=false --set introduceRandomResponseLagValue=0 --namespace $APP_NS

helm upgrade $APP_IN multicalculator --install --set backendReplicaCount=3 --set frontendReplicaCount=3 --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set introduceRandomResponseLag=true --set introduceRandomResponseLagValue=3 --namespace $APP_NS --dry-run --debug
```

## Rollout history and rollbacks

1. See rollout history
```
helm history $APP_IN -n $APP_NS
helm rollback $APP_IN 2 -n $APP_NS
```

1. Cleanup
```
helm delete $APP_IN -n $APP_NS
```