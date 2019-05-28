# Kubernetes 101 Challenge

For scheduling applications consisting of multiple containers you typically use an orchestrator. Kubernetes is an orchestrator and in this chapter you will set up a Kubernetes cluster in Azure Kubernetes Service (AKS) and an Azure Container Registry (ACR) to store your images.

![](/img/challenge2.png)

---

## What you will learn

- How to set up a Kubernetes Cluster with Azure Kubernetes Services
- How to access the cluster with the commandline command `kubectl`
- Get to know the basic command set of `kubectl`
- Understand the concept of pods and services and how they come together
- Get in touch with Yaml files to specify a desired state for a Kubernetes object

---

## 1. Create a Kubernetes cluster using Azure DevOps Project

- Set up your Kubernetes cluster using Azure Kubernetes Services. To get up to speed quickly we use an **Azure DevOps Project** to do this for us. However this could also be done manually.

> Use simple node app, create new cluster, set kubernetes version to 12.8, set for westeurope, get credentials [here :blue_book:](hints/createdevopsproject.md)!
>
> If you want to create a cluster via cli use this one [here :blue_book:](hints/create_aks_cluster.md)!

The deployment will take some time (~10 min). If you created your cluster using Azure DevOps Projects you will see the cluster only after running the full pipeline. Check your Azure resource groups to see if you find your Kubernetes service.

If you want you can create the cluster using Terraform and the example Terraform script [here :blue_book:](hints/terraform.md)!

## 2. Run single container app in your K8s cluster

> This is about running your first container in Kubernetes
>
> Need help? Check hints [here :blue_book:](hints/k8sSingle.md)!

- Run a public available application in a single container on your cluster. The image name is `nginx`.
  - Use the `kubectl run` command to create an individual pod
  - Use the `kubectl create` command to create a desired state configuration using a deployment
- Add a service to make your application accessible from the internet
  - Use the `kubectl expose` and `kubectl edit YOURSERVICE` commands.
- Start your webbrowser to view your application running in your cluster.

## 3. Kubernetes discovery

> This is about learning the Kubernetes objects
>
> Need help? Check hints [here :blue_book:](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)!

- If you want to work with namespaces. Create your own namespace like `dennisspace` and apply this postfix to your `kubectl` commands like shown below:

  ```bash
  kubectl create ns dennisspace

  kubectl run meinnginx --generator=run-pod/v1 --image=nginx -n dennisspace

  kubectl get pods -n dennisspace
  ```

- Familiarize yourself with the following commands on commandline

  ```bash
  # display all pods
  kubectl get pods

  # display all services
  kubectl get svc

  # display all deployments
  kubectl get deployments

  # delete a specific pod
  kubectl delete pods/<podid>

  # look up yaml for a deployment
  kubectl describe deployment <deploymentname>
  ```

## 4. Execute deployments via yaml

> This is about creating a desired state configration for your apps
>
> Need help? Check hints [here :blue_book:](hints/learn_yaml_files.md)! [here :blue_book:](hints/create_secrets.md)!

- Launch the nginx deployment via yaml file (see if you can download it somewhere?)
- Launch a custom image from your registry (learn about secrets or registry authentication) [here :blue_book:](hints/yaml/aci-helloworld-reg.yaml)!
- You can declare a namespace inside your yaml file
- Delete the frontend pod using the commandline and call the website again.
- You'll recognize that it will no longer work - but they restart?

## BONUS Challenge - Scaling apps automatically

> Need help? Check hints [here :blue_book:](hints/create_traffic.md)!

- Configure your deployment to ensure that the number of replicas scales automatically according to the load
- Configure a horizontal pod autoscaler for your deployment
- Create some traffic to ensure that the scale operation starts
- Evaluate the azure monitor to see performance metrics
