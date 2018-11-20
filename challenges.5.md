# Kubernetes integration challenge
> Need help? Check hints [here :blue_book:](hints/osba.md)! (hints/helm.md)!

> In this challenge you will extend your application plattform capabilities with the vast set of services of native Azure PaaS Services - by using SQL, Redis Cache, MySQL, Service Bus, Cosmos DB from your apps. You will make sure that the management of these services will be done by the service catalog in Kubernetes and minimize the impact of your operational teams to use Azure PaaS.

## Here's what you'll learn:
> - How to persist data in a container
> - How to set up the open service broker api for your Cluster
> - Learn how to package application and their dependencies using HELM
> - Successfully deploy the multicalculator and the Redis Cache dependency

## 1. Mount a volumne
- Configure a storage class
- Deploy a pod and mount a volume from a persistent volume
- Have the application write to that volume
- Use redis in a sidecar container to

## 2. Deploy an ingress controller
- Learn about ingress controller (https://kubernetes.io/docs/concepts/services-networking/ingress/)
- Deploy an ingress controller via Helm (https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress)
- Configure the routes for ingress to your application (https://docs.microsoft.com/en-us/azure/aks/ingress)

## 3. Install the open service broker api
- Configure your azure service principal for the open service broker
- Deploy the azure open service broker into your AKS service catalog
- Verify that it works by deploying wordpress 

## 4. Integrate using the open service broker
![](/img/appmapredis.jpg)
- Expand the requirements for your helm chart
- Define naming and parametery for your helm chart to make use of the Azure Redis Cache
- Deploy your app!
