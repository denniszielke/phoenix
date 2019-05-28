# Kubernetes security challenge

> Need help? Check hints [here :blue_book:](hints/osba.md)! (hints/helm.md)!

In this challenge you will learn how to lock down your application for enterprise use.

![](/img/challenge6.png)

---

## What you will learn

- Deploying ingress with ssl termination
- Using network policies to lock down internal traffic
- Using authentication proxy to enforce auth at the ingress
- Move secrets to Azure Key Vault

---

## 1. Deploy a secure ingress

https://docs.microsoft.com/en-us/azure/aks/ingress-tls

## 2. Deploy network policies

Deploy the network policy daemonset

```bash
kubectl apply -f https://github.com/Azure/acs-engine/blob/master/parts/k8s/addons/kubernetesmasteraddons-azure-npm-daemonset.yaml
```

## 3. Configure auth proxy

https://github.com/buzzfeed/sso

## 4. Move secrets to Key Vault

https://github.com/Azure/kubernetes-keyvault-flexvol
