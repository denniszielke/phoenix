# Create an Azure DevOps Project
1. In Azure Portal create a new DevOps project (Click "create a resource", then search for DevOps)
1. Select Node.js as language
1. Select Simple Node.js App
1. Select Kubernetes Service as deployment target
 
1. In the final dialog chose a name for your project and pick your DevOps Org. If you don't have a DevOps Org yet, click Additional Settings and specify a name for it. If you already have one, you can chose this one.
1. Select to create a new AKS cluster.
1. As location choose North Europe everywhere (also for AppInsights, Log location and Registry in additional Settings)
1. It should look like this:
![](/hints/images/devopsproject1.jpg)

1. After this you have
- a DevOps organization 
- a build & release pipeline
- demo source code for a node.js app
1. The build will kick off automatically. During the build a Container Registry will be created. During release the AKS cluster will be created.

After cluster creation set up your work environment (or bash) to enable cluster access. See the hints at the lower part of this file [here :blue_book:](create_aks_cluster.md)! 

# Get access to cluster

1. Get the environment variables for the first cluster
```
KUBE_NAME=$(az aks list --query '[0].{NAME:name}' -o tsv) 
KUBE_GROUP=$(az aks list --query '[0].{RESOURCEGROUP:resourceGroup}' -o tsv)
```

1. Export the kubectrl credentials files. 
```
az aks get-credentials --resource-group=$KUBE_GROUP --name=$KUBE_NAME
```

1. Now you can look at the cluster config file under
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
