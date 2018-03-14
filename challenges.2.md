# Kubernetes 101 Challenge
> For scheduling applications consisting of multiple containers you typically use an orchestrator. Kubernetes is an orchestrator and in this chapter you will set up a Kubernetes cluster in Azure Container Services (ACS) and an Azure Container Registry (ACR) to store your images.
>## Here's what you'll learn:
> - How to set up a Kubernetes Cluster with Azure Container Services
> - How to access the cluster with the commandline command "kubectl"
> - Get to know the basic command set of "kubectl"
> - Understand the concept of pods and services and how they come together
> - Get in touch with Yaml files to specify a desired state for a Kubernetes object


## 1. Create a Kubernetes cluster on Azure Container Services 
- Set up your Kuberenetes cluster using Azure Container Services.
> Need help? Check hints [here :blue_book:](hints/createk8scluster.md)!

The deployment will take some time (~20 min). 

## 2. Run single container app in your K8s cluster
> Need help? Check hints [here :blue_book:](hints/k8sSingle.md)!
- Run a public available application in a single container on your cluster. The image name is "nginx".
    - Use the "kubectl run" command
- Add a service to make your application accessible from the internet
    - Use the "kubectl expose" command and "kubectl edit YOURSERVICE" command.
- Start your webbrowser to view your application running in your cluster.

## 3. Kubernetes discovery
- Open the K8s portal for a graphical interface. Run `kubectl proxy`then open up a browser an navigate to http://localhost:8001/ui or http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/pod?namespace=default
- If you want to work with namespaces. Create your own namespace 'dennisspace' with 
```
kubectl create ns dennisspace
```
and apply this postfix to your  kubectl commands like 
```
kubectl get pods -n dennisspace
```

- Familiarize yourself with the following commands on commandline, eg.
```
kubectl get pods    // to display all pods
kubectl get svc     // to display all services
kubectl get deployments     // to display all deployments
kubectl delete pods/<podid> // to delete a specific pod

```

## 4. Execute deployments via yaml
> Need help? Check hints [here :blue_book:](hints/yamlfiles.md)!

- Launch the nginx deployment via yaml file (see if you can download it somewhere?)
- Launch a custom image from your registry (learn about secrets)
- You can declare a namespace inside your yaml file
