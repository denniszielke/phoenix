# Using Helm

## Installing helm and tiller

https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm (not required for azure shell)

```bash
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz

tar -zxvf helm-v2.12.0-linux-amd64.tar.gz

mv linux-amd64/helm /usr/local/bin/helm
```

If you are unsure if your cluster is set up with RBAC please check by running

```bash
kubectl cluster-info dump --namespace kube-system | grep authorization-mode
```

> **Warning:** If your cluster has been set up with RBAC you have to create a role for tiller first

```bash
kubectl create serviceaccount tiller --namespace kube-system

kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller \
  --namespace kube-system

helm init --service-account tiller --upgrade
```

Install tiller and upgrade tiller for NON-RBAC clusters

```bash
helm

helm init
echo "Upgrading tiller..."
helm init --upgrade
echo "Upgrading chart repo..."
helm repo update
```

See all pods (including tiller)

```bash
kubectl get pods --namespace kube-system

helm version
```

reinstall or delete tiller

```bash
helm reset
```

Find and install helm charts from https://kubeapps.com/

## Create your own helm chart

1. Create helm chart manually and modify accordingly

   ```bash
   helm create dummychart
   ```

   Validate template

   ```bash
   helm lint ./dummychart
   ```

1. Dry run the chart and override parameters

   ```bash
   APP_NS=calculator
   APP_IN=calc1

   kubectl create ns $APP_NS

   helm install \
    --dry-run --debug ./multicalchart \
    --set frontendReplicaCount=3 \
    --name=$APP_IN \
    --set dependencies.appInsightsSecretValue=\$APPINSIGHTS_KEY
   ```

1. Install

   ```bash
   helm install multicalchart \
    --set frontendReplicaCount=4 \
    --set frontendReplicaCount=3 \
    --name=$APP_IN \
    --set dependencies.useAppInsights=true \
    --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY \
    --namespace=\$APP_NS
   ```

   verify

   ```bash
   helm get values \$APP_IN
   ```

1. Change config and perform an upgrade (change the backend image to to the go version)

   ```bash
   helm upgrade multicalchart \
     --set frontendReplicaCount=4 \
     --set frontendReplicaCount=3 \
     --name=$APP_IN \
     --set dependencies.useAppInsights=true \
     --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY \
     -set image.backendImage=go-calc-backend \
     --namespace=\$APP_NS
   ```

1. Change config and perform an upgrade (add a redis cache to the frontend pod)

   ```bash
   helm upgrade multicalchart \
     --set frontendReplicaCount=4 \
     --set frontendReplicaCount=3 \
     --name=$APP_IN \
     --set dependencies.useAppInsights=true \
     --set dependencies.appInsightsSecretValue=$APPINSIGHTS_KEY \
     --set dependencies.usePodRedis=true \
     --namespace=\$APP_NS
   ```

1. See rollout history

   ```bash
   helm history $APP_IN

   helm rollback $APP_IN 1
   ```

1. Cleanup

   ```bash
   helm delete \$APP_IN --purge
   ```
