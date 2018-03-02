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

Install docker via package
~~~
sudo apt install docker.io
~~~

On Ubuntu make sure that the current user is part of the docker group
~~~
sudo usermod -aG docker $USER
~~~
Log in and out to re-evaluate your group membership

## Creating a service principal for Kubernetes

Azure Portal
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/azure-resource-manager/resource-group-create-service-principal-portal.md#create-an-azure-active-directory-application

Azure cli
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/container-service/kubernetes/container-service-kubernetes-service-principal.md#option-1-create-a-service-principal-in-azure-ad 

