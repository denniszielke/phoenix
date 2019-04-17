# Kubernetes security challenge
> Need help? Check hints [here :blue_book:](hints/osba.md)! (hints/helm.md)!

> In this challenge you will learn how to lock down your application for enterprise use.

![](/img/challenge6.png)

## Here's what you'll learn:
> - Deploying ingress with ssl termination
> - Using network policies to lock down internal traffic
> - Using authentication proxy to enforce auth at the ingress
> - Move secrets to azure key vault

## 1. Deploy a secure ingresss
https://docs.microsoft.com/en-us/azure/aks/ingress-tls

## 2. Deploy network policies

Deploy the network policy daemonset
```
kubectl apply -f  https://github.com/Azure/acs-engine/blob/master/parts/k8s/addons/kubernetesmasteraddons-azure-npm-daemonset.yaml
```

## 3. Configure auth proxy
https://github.com/buzzfeed/sso

## 4. Move secrets to keyvault
https://github.com/Azure/kubernetes-keyvault-flexvol