# Using Helm

## Installing helm and tiller
https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm (not required for azure shell)
```
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz
tar -zxvf helm-v2.12.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
```

If you are unsure if your cluster is set up with RBAC please check by running
```
kubectl cluster-info dump --namespace kube-system | grep authorization-mode

***Warning***: If your cluster has been set up with RBAC you have to create a role for tiller first
```
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --namespace kube-system
helm init --service-account tiller --upgrade
```

Install tiller and upgrade tiller for NON-RBAC clusters
```
helm

helm init
echo "Upgrading tiller..."
helm init --upgrade
echo "Upgrading chart repo..."
helm repo update
```

See all pods (including tiller)
```
kubectl get pods --namespace kube-system
helm version
```

reinstall or delte tiller
```
helm reset
```

Find and install helm charts from https://hub.helm.sh/

## Create your own helm chart

1. Create helm chart manually and modify accordingly

```
helm create dummychart
```

Validate template
```
helm lint ./dummychart
```

2. Dry run the chart and override parameters
```
APP_NS=calculator
APP_IN=calc1
kubectl create ns $APP_NS
helm install --dry-run --debug ./multicalchart --set frontendReplicaCount=3 --name=$APP_IN
```

You should see the dry run yaml output that would have been sent to tiller

3. Now install the helm chart for real
```
helm install multicalchart --set frontendReplicaCount=4 --set frontendReplicaCount=3 --name=$APP_IN --namespace=$APP_NS
```

verify
```
helm get values $APP_IN
```

4. Change config and perform an upgrade (change the backend image to to the go version and/or add application insights)
```
helm upgrade multicalchart --set frontendReplicaCount=4 --set frontendReplicaCount=3 --name=$APP_IN --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY -set image.backendImage=go-calc-backend --namespace=$APP_NS
```

5. Change config and perform an upgrade (add a redis cache to the frontend pod)
```
helm upgrade multicalchart --set frontendReplicaCount=4 --set frontendReplicaCount=3 --name=$APP_IN --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true --namespace=$APP_NS
```

The performance might be better if you use an azure redis cache. Create a redis cache
```
az redis create --location $LOCATION --name myownredis --resource-group $KUBE_GROUP --sku Basic --enable-non-ssl-port
```


If you have a redis secret you can turn on the redis cache
```
REDIS_HOST=myownredis.redis.cache.windows.net
REDIS_AUTH=Idfsdfsd+Bs=
helm upgrade $APP_IN multicalchart --set backendReplicaCount=3 --set frontendReplicaCount=3 --set dependencies.useAppInsights=false --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --namespace $APP_NS
```

6. You can introduce faults, delays and errors in the backend by using the following config:
```
helm upgrade $APP_IN multicalchart --set backendReplicaCount=3 --set frontendReplicaCount=3 --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH --set introduceRandomResponseLag=false --set introduceRandomResponseLagValue=0 --namespace $APP_NS
```

7. See rollout history
```
helm history $APP_IN
helm rollback $APP_IN 2
```

8. Cleanup
```
helm delete $APP_IN --purge
```