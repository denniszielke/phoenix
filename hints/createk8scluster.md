# Create container cluster
https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

**Hint:** The "set KEY value" values commands work in Powershell. In Bash use KEY=value.

1. Use bash to create the resource group by using azure cloud shell (https://shell.azure.com/ )
```
LOCATION=eastus
KUBE_GROUP=myKubeRG
KUBE_NAME=myFirstKube
az group create -n $KUBE_GROUP -l $LOCATION
```

2. Create the aks cluster
```
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

4. Now you can look at the cluster config file under
```
cat ~/.kube/config
```

5. Download the config file from ~/.kube/config to your local disk.
If you are running windows do the following
- Open a cmd.exe windows
- Enter  to move to your user profile directory
```
cd %HOMEPATH%
```
- Create a folder named .kube 
``` 
mkdir .kube
```
- Copy the file named "config" (no extension) to your .kube folder or create the file and copy its contents (look out for line breaks).

If you are running linux create create a folder named ".kube" in your home directory and move the config file there

6. Download kubectl for your plattform
https://kubernetes.io/docs/tasks/tools/install-kubectl/ 

7. Check that everything is running ok
```
kubectl cluster-info
```
8. Launch the dashboard
```
kubectl proxy
```

Go to kubernetes dashoard
http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/pod?namespace=default 
