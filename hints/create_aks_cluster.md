# Create a kubernetes cluster
https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#create-aks-cluster

**Hint:** The "set KEY value" values commands work in Powershell. In Bash use KEY=value.


1. Use bash to create the resource group by using azure cloud shell (https://shell.azure.com/ )
```
LOCATION=northeurope
KUBE_GROUP=myKubeRG
KUBE_NAME=myFirstKube
az group create -n $KUBE_GROUP -l $LOCATION
```

2. Create the aks cluster using azure shell

```
az aks create --name $KUBE_NAME --resource-group $KUBE_GROUP --node-count 3 --generate-ssh-keys --enable-addons monitoring --kubernetes-version 1.15.7 --enable-rbac
```
Additional parameters can be found here https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create
if you have to use the given service principal (because you are not allowed to create services principals in azure ad) add the following parameters
```
--client-secret HEREBESECRET --service-principal HEREBEAPPID
```
Customize the vm size with
Look up vm sizes 
```
az vm list-sizes -l westeurope
```
and set as parameter
```
--node-vm-size Standard_B2s
```

# Get access to cluster

3. Export the kubectrl credentials files. 
```
az aks get-credentials --resource-group=$KUBE_GROUP --name=$KUBE_NAME
```

4. Now you can look at the cluster config file under
```
cat ~/.kube/config
```

You can download the latest version of kubectl (only for local machine - azure shell already has kubectl)
```
az aks install-cli 
```

Alternatively for your plattform
https://kubernetes.io/docs/tasks/tools/install-kubectl/ 

Set up autocompletion
```
kubectl completion -h
```

5. Check that everything is running ok
```
kubectl cluster-info
```

6. Launch the dashboard
in the azure shell (look for the url in the output and click on it - you will be directed to the dashboard)
```
az aks browse --resource-group $KUBE_GROUP --name $KUBE_NAME
```

or locally 

```
kubectl proxy
http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/pod?namespace=default 
```

7. If you see an access denied - you have to give the dashboard pod permissions first
```
kubectl create clusterrolebinding kubernetes-dashboard \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:kubernetes-dashboard
```
