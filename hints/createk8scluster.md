# Create container cluster
https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-walkthrough

**Hint:** The "set KEY value" values commands work in Powershell. In Bash use KEY=value.

1. Create the resource group
```
set LOCATION westus
set KUBE_GROUP myKubeRG
az group create -n $KUBE_GROUP -l $LOCATION
```

2. Create the acs cluster
```
set KUBE_NAME myFirstKube
az acs create --name $KUBE_NAME --resource-group $KUBE_GROUP --orchestrator-type Kubernetes --dns-prefix $KUBE_NAME --generate-ssh-keys
```
Additional parameters can be found here https://docs.microsoft.com/en-us/cli/azure/acs?view=azure-cli-latest#az_acs_create
if you have to use the given service principal (because you are not allowed to create services principals in azure ad) add the following parameters
```
--client-secret HEREBESECRET --service-principal HEREBEAPPID
```
3. Export the kubectrl credentials files. 
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
kubectl config current-context
```

Use flag to use context if multiple clusters are in use
```
kubectl config use-context
```
