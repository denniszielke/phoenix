# Compact version of Kubernetes challenges for beginners

## *Compact Challenge 1.* Create an AKS cluster
- Create a new instance of Kubernetes Service in Azure using the portal
    - How to setup AKS docs https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal
- Install kubeclt locally (on your laptop) or work in cloud shell for subsequent steps
    - How to setup Cloud Shell https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart
    - Install Kubectl on your machine https://github.com/denniszielke/phoenix/blob/master/hints/createdevopsproject.md or use az aks install-cli
- Configure your machine to connect to your cluster using kubectl
    - Hint: https://github.com/denniszielke/phoenix/blob/master/hints/createdevopsproject.md#get-access-to-cluster

## *Compact Challenge 2.* Create an application container with ACR
- create an Azure Container Registry
    - docs: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal
- clone this git repo (the one your're currently reading) to your machine (or to cloudshell)
    - Run: git clone https://github.com/denniszielke/phoenix/
- build the container for a very simple app found in /apps/helloworld using ACR build quick tasks 
    - docs: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview#quick-task
    - example: https://github.com/denniszielke/phoenix/blob/master/hints/acr_task_github_trigger.md#manually-build-a-container

## *Compact Challenge 3.* Deploy your container to AKS and work with kubectl
- run your newly created container image in your cluster using kubectl
    - you may have to give permissions to your ACR spn (use az aks list to figure it out)
    - or you may wanna work with kubernetes secrets https://github.com/denniszielke/phoenix/blob/master/hints/create_secrets.md
- run kubectl get commands to investigate what's going on in your cluster
    - find some hints here: https://github.com/denniszielke/phoenix/blob/master/hints/k8sSingle.md


## *Compact Challenge 4.* Understand Pods, Services, Labels & Selectors and discover Kubernetes
- This is where the fun starts. Try to understand what's going on!
- Expose the app you deployed in step 3 to your cluster as a service and access it
    - find some hints here: https://github.com/denniszielke/phoenix/blob/master/hints/k8sSingle.md
    - also check this out: https://github.com/denniszielke/phoenix/blob/master/hints/k8sSingle.md

## *Compact Challenge 5.* Deploy a yaml definiton to your cluster
- pick a sample yaml file found in /hints/yaml/full-depl-no-appinsights.yaml and deploy it to your cluster
    - see the hints here https://github.com/denniszielke/phoenix/blob/master/hints/k8sSingle.md 
- open a browser and check if the app is running correctly
