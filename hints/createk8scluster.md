# Create container cluster
https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

**Hint:** The "set KEY value" values commands work in Powershell. In Bash use KEY=value.

1a. Create the resource group (Powershell)
```
set LOCATION westus
set KUBE_GROUP myKubeRG
az group create -n $KUBE_GROUP -l $LOCATION
```


1b. OR use bash to create the resource group 
```
LOCATION=eastus
KUBE_GROUP=myKubeRG
az group create -n $KUBE_GROUP -l $LOCATION
```

2. Create the acs cluster
```
set KUBE_NAME myFirstKube
az aks create --name $KUBE_NAME --resource-group $KUBE_GROUP --node-count 3 --generate-ssh-keys --kubernetes-version 1.8.7
```
Additional parameters can be found here https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create
if you have to use the given service principal (because you are not allowed to create services principals in azure ad) add the following parameters
```
--client-secret HEREBESECRET --service-principal HEREBEAPPID
```
3. Export the kubectrl credentials files. 
```
az aks get-credentials --resource-group=$KUBE_GROUP --name=$KUBE_NAME
```

or If you are not using the Azure Cloud Shell and don’t have the Kubernetes client kubectl, run 
```
sudo az aks install-cli

scp azureuser@$KUBE_NAMEmgmt.eastus.cloudapp.azure.com:.kube/config $HOME/.kube/config
```
4. Download kubectl for your plattform
https://kubernetes.io/docs/tasks/tools/install-kubectl/ 

5. Check that everything is running ok
```
kubectl version
kubectl config current-context
```

Use flag to use context if multiple clusters are in use
```
kubectl config use-context
```
