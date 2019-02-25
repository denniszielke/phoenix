# Using Helm

## Installing helm and tiller
https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm
```
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz
tar -zxvf helm-v2.12.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
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

Find and install helm charts from https://kubeapps.com/

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
helm install --dry-run --debug ./multicalchart --set frontendReplicaCount=3 --name=$APP_IN --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY
```

Optionally make sure you have the app insights key secret provisioned
```
APPINSIGHTS_KEY=
kubectl create secret generic appinsightsecret --from-literal=appinsightskey=$APPINSIGHTS_KEY -n $APP_NS
```

3. Install
```
helm install multicalchart --name=$APP_IN --set frontendReplicaCount=1 --set backendReplicaCount=1 --namespace $APP_NS
```

verify
```
helm get values $APP_IN
```

4. Change config and perform an upgrade
```
helm upgrade --set backendReplicaCount=4 $APP_IN multicalchart
```

5. See rollout history
```
helm history $APP_IN
helm rollback $APP_IN 1
```

6. Cleanup
```
helm delete $APP_IN --purge
```
