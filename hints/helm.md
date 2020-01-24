# Using Helm

## Installing helm and tiller
https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm (not required for azure shell) on your own machine: https://github.com/helm/helm#install

> We are using Helm 3 - if you have helm2 installed please check the version before and upgrade to helm3.

If you are unsure if your cluster is set up with RBAC please check by running
```
kubectl cluster-info dump --namespace kube-system | grep authorization-mode
```
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

Perform a dry run of an installation
```
helm upgrade dummyInstanceName ./dummychart --install --dry-run --debug
```

Check the output

## Deploy the existing multicalchart

2. Dry run the chart and override parameters
```
cd /phoenix/apps
APP_NS=calculator
APP_IN=calc1
kubectl create ns $APP_NS
helm upgrade $APP_IN ./multicalculatorv3 --namespace $APP_NS --install --dry-run --debug
```

You should see the dry run yaml output that would have been sent to tiller

3. Now install the helm chart for real
```
helm upgrade $APP_IN ./multicalculatorv3 --namespace $APP_NS --install
```

verify
```
helm list -n $APP_NS
helm get values $APP_IN $APP_IN
```

4. Change config and perform an upgrade (change the backend image to to the go version and/or add application insights)
```
helm upgrade $APP_IN ./multicalculatorv3 --namespace $APP_NS --install
```

5. Change config and perform an upgrade (add a redis cache to the frontend pod)
```
APPINSIGHTS_KEY=
helm upgrade $APP_IN ./multicalculatorv3 --namespace $APP_NS --install  --set replicaCount=4  --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true
```

Check the values
```
helm get values $APP_IN $APP_IN
```

The performance might be better if you use an azure redis cache. Create a redis cache
```
az redis create --location $LOCATION --name myownredis --resource-group $KUBE_GROUP --sku Basic --enable-non-ssl-port
```


If you have a redis secret you can turn on the redis cache
```
REDIS_HOST=myownredis.redis.cache.windows.net
REDIS_AUTH=Idfsdfsd+Bs=
helm upgrade $APP_IN ./multicalculatorv3 --namespace $APP_NS --install  --set replicaCount=4  --set dependencies.useAppInsights=true --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY --set dependencies.usePodRedis=true
--set dependencies.useAzureRedis=true --set dependencies.redisHostValue=$REDIS_HOST --set dependencies.redisKeyValue=$REDIS_AUTH
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