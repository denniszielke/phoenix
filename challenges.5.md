# Security- Challenge
> Need help? Check hints [here :blue_book:] (hints/helm.md)!

## Why
Especially when running multiple applications in your cluster you want to controll how traffic is coming into your environment and how different worloads are allowed to communicate within the cluster. In this challenge you will learn how to lock down your application for enterprise use.

![](/img/challenge5.png)

## Here's what you'll learn:
> - Deploying ingress with ssl termination
> - Using network policies to lock down internal traffic
> - Using authentication proxy to enforce auth at the ingress
> - Move secrets to azure key vault

## 1. Deploy an ingress controller
- Learn about ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress/)
- Deploy an ingress controller via Helm (https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress)
- Configure the routes for ingress to your application (https://docs.microsoft.com/en-us/azure/aks/ingress)

## 2. Deploy network policies
- Learn about how to control traffic flows between containers https://docs.microsoft.com/de-de/azure/aks/use-network-policies

Deploy the network policy daemonset
```
kubectl apply -f  https://github.com/Azure/acs-engine/blob/master/parts/k8s/addons/kubernetesmasteraddons-azure-npm-daemonset.yaml
```

## 3. Configure a network security group
- Learn about having Kubernetes manage your azure network security group. 
- Can you whitelist so that only specific ip ranges are allowed to your ingress controller?
https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/

## 4. Move secrets to keyvault
- Learn about moving secrets from your cluster to an azure keyvault
- Check out what you need to do: https://github.com/Azure/kubernetes-keyvault-flexvol