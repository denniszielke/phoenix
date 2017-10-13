# Create container cluster
https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-walkthrough

1. Create the resource group
```
az group create -n $KUBE_GROUP -l $LOCATION
```

2. Create the acs cluster
```
az acs create --name $KUBE_NAME --resource-group $KUBE_GROUP --orchestrator-type Kubernetes --dns-prefix $KUBE_NAME --generate-ssh-keys
```

3. Export the kubectrl credentials files
```
az acs kubernetes get-credentials --resource-group=$KUBE_GROUP --name=$KUBE_NAME
```

or If you are not using the Azure Cloud Shell and don’t have the Kubernetes client kubectl, run 
```
sudo az acs kubernetes install-cli

scp azureuser@$KUBE_NAMEmgmt.westeurope.cloudapp.azure.com:.kube/config $HOME/.kube/config
```

4. Check that everything is running ok
```
kubectl version
kubectl config current-contex
```

Use flag to use context if multiple clusters are in use
```
kubectl --kube-context
```