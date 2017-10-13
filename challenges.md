# Single Container Loop 
In this chapter you will get a basic experience in working with containers. For this chapter we concentrate on single container applications running locally or in Azure Container Instances.


1. Containerize your app 
- Get the sample code of our application **here**. **TODO LINK MISSING**
- Create a container image locally
- Run the image in a container locally on your machine.

2. Automate your build 
- Use VSTS to create a build definition which triggers on code changes. The build definition should 
    - create a new container image 
    - push the new image to your private Azure Container Registry (if you don't have an ACR, create one first)

3. Release to ACI manually
- Run your newly created image in Azure Container Instances to see if everything works. You can start it manually in the portal or via command line.

4. Relase to ACI via VSTS
- Use VSTS to create a release definition which is triggered by your build definition. This release definition should
    - deploy the latest image created by your build definition to ACI
- Now you have a full end to end flow for single container applications.

4. Gain insights via Application Insights

**TODO**

# Kubernetes 101 
In this chapter you will set up a Kubernetes cluster in Azure Container Services (ACS) and an Azure Container Registry (ACR) to store your images.

1. Create a Kubernetes cluster on Azure Container Services 
- Follow the instructions found here to set up your cluster
The deployment will take some time (~20 min). 

1. Run single container app in your K8s cluster
- Run your application in a single container on your cluster
- Make your application accessible from the internet

1. Kubernetes discovery
- Open the K8s portal

# Kubernetes Multicontainer 
1. Kubernetes multi container app deployment 
- Get the sample code for a multi container application here 
- Build the container images for frontend and backend services
- Run the container images in your Kubernetes cluster
- Configure your 


2. Manual deployment via ReplicationController 

*TODO*


# VSTS YAML deployment
1. Modifiy Rollback, Scaling​
Kubernetes toolchain ​
Helm (30) with Ingress Controller (30)​
Monitorng with OMS for Infrastructure (30)​
​
​
​
​
​