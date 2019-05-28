# Create a kubernetes cluster

https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#create-aks-cluster

> **Hint:** The `set KEY value` values commands work in Powershell. In Bash use `KEY=value`.

1. Use bash to create the resource group by using azure cloud shell (https://shell.azure.com/ )

   ```bash
   LOCATION=westeurope
   KUBE_GROUP=myKubeRG
   KUBE_NAME=myFirstKube
   az group create -n $KUBE_GROUP -l $LOCATION
   ```

2. Create the aks cluster using azure shell

   ```bash
   az aks create \
     --name $KUBE_NAME \
     --resource-group $KUBE_GROUP \
     --node-count 3 \
     --generate-ssh-keys \
     --enable-addons monitoring \
     --kubernetes-version 1.12.6
   ```

   Additional parameters can be found here https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create

   If you have to use the given service principal (because you are not allowed to create services principals in azure ad) add the following parameters

   ```bash
   --client-secret HEREBESECRET --service-principal HEREBEAPPID
   ```

   Customize the vm size by looking up vm sizes

   ```bash
   az vm list-sizes -l westeurope
   ```

   and set as parameter

   ```bash
   --node-vm-size Standard_B2s
   ```

# Get access to cluster

1. Export the kubectrl credentials files.

   ```bash
   az aks get-credentials --resource-group=$KUBE_GROUP --name=$KUBE_NAME
   ```

1. Now you can look at the cluster config file under

   ```bash
   cat ~/.kube/config
   ```

   You can download the latest version of kubectl (only for local machine - azure shell already has kubectl)

   ```bash
   az aks install-cli
   ```

   Alternatively for your plattform
   https://kubernetes.io/docs/tasks/tools/install-kubectl/

   Set up autocompletion

   ```bash
   kubectl completion -h
   ```

1. Check that everything is running ok

   ```bash
   kubectl cluster-info
   ```

1. Launch the dashboard in the azure shell (look for the url in the output and click on it - you will be directed to the dashboard)

   ```bash
   az aks browse --resource-group $KUBE_GROUP --name $KUBE_NAME
   ```

   or locally

   ```bash
   kubectl proxy
   http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/pod?namespace=default
   ```

1. If you see an access denied - you have to give the dashboard pod permissions first

   ```bash
   kubectl create clusterrolebinding kubernetes-dashboard \
     --clusterrole=cluster-admin \
     --serviceaccount=kube-system:kubernetes-dashboard
   ```
