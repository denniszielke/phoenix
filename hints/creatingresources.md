# Hints for creating resources in Azure

## Creating a container registry on Azure

Via the portal:
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal

Via Powershell:
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-powershell

Via Azure CLI:
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli

## Install docker on Ubuntu 16.04 LTS (do not use the docker ubuntu vm from marketplace) in Azure
* To install the VM, log into the Azure portal, click "Create new Resource", search for "Ubuntu 16.04 LTS" and follow the wizard. It is recommended to enable auto-shut down.
* After deployment, log into the new VM. To access it either log into it via  ssh from your client (e.g from Bash on Windows).

1. Install docker via package manager (https://docs.docker.com/install/linux/docker-ce/ubuntu/) 
```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
```

2. On Ubuntu make sure that the current user is part of the docker group
~~~
sudo usermod -aG docker $USER
~~~
Log in and out to re-evaluate your group membership

3. Test docker engine
~~~
sudo docker run hello-world
~~~

## Creating a service principal for Kubernetes

Azure Portal
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/azure-resource-manager/resource-group-create-service-principal-portal.md#create-an-azure-active-directory-application

Azure cli
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/container-service/kubernetes/container-service-kubernetes-service-principal.md#option-1-create-a-service-principal-in-azure-ad 

