# Hints for the integration challenge

## Install Helm
# Using Helm

## Installing helm and tiller
https://github.com/kubernetes/helm
https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

Install helm
```
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz
tar -zxvf helm-v2.7.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

Install tiller and upgrade tiller
```
helm

helm init
echo "Upgrading tiller..."
helm init --upgrade
echo "Upgrading chart repo..."
helm repo update
```

If you are on 2.7.2 and want explicitly up/downgrade to 2.6.1:
```
export TILLER_TAG=v2.6.1
kubectl --namespace=kube-system set image deployments/tiller-deploy tiller=gcr.io/kubernetes-helm/tiller:$TILLER_TAG
```

See all pods (including tiller)
```
kubectl get pods --namespace kube-system
```

reinstall or delte tiller
```
helm reset
```

helm install stable/mysql
https://kubeapps.com/

## Create your own helm chart

1. Create using draft
Go to app folder and launch draft
https://github.com/Azure/draft 
```
draft create
```

2. Create helm chart manually and modify accordingly

```
helm create multicalc
```
Validate template
```
helm lint ./multicalchart
```

3. Dry run the chart and override parameters
```
helm install --dry-run --debug ./multicalchart --set frontendReplicaCount=3
```

4. Make sure you have the app insights key secret provisioned
```
kubectl create secret generic appinsightsecret --from-literal=appinsightskey=$APPINSIGHTS_KEY
```

5. Install
```
helm install multicalchart --name=calculator --set frontendReplicaCount=1 --set backendReplicaCount=1 --set image.frontendTag=redis --set image.backendTag=redis
```

verify
```
helm get values calculator
```

6. Change config and perform an upgrade
```
helm upgrade --set backendReplicaCount=4 calculator multicalchart
```

7. See rollout history
```
helm history calculator
helm rollback calculator 1
```

6. Cleanup
```
helm delete calculator --purge
```

## Learn about OSBA for Azure
https://docs.microsoft.com/en-us/azure/aks/integrate-azure

## Learn about Helm charts 
https://github.com/kubernetes/charts

## Check example of OSBA for Azure
https://github.com/Azure/helm-charts
