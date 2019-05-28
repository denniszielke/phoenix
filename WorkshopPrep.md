# Prepare workshop

## Create Resources

1. [Create a dedicated Service Principal for AKS](https://github.com/denniszielke/container_demos/blob/master/CreateServicePrincipal.md)
1. Create Resource Group for AKS API Server
1. Assign Contributor Permissions to SP for API Server Resource Group + Add all Workshop participants as Contributor to the Resource Group
1. [Create Azure Container Registry](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-acr) in the API Server Resource group - if not make sure that the AKS Service Principal has at least "Reader" permissions to the container registry.
1. [Create the AKS Cluster](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster#create-kubernetes-cluster)
1. [Install kubectl, get kubeconfig and connect to the cluster](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster#create-kubernetes-cluster)
1. [Deploy azure container health](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-health#enable-container-health-monitoring-for-a-new-cluster)
1. Get the kubeconfig from `~/.kube/config` and share it with the group

## Prep for each participant

1. [Install the azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
1. [Install VSCode](https://code.visualstudio.com/)
1. [Install kubectl](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster)
1. Copy the kubeconfig file to `~/.kube/config` (Mac or Linux) or to `%HOMEPATH%\.kube\config` (Windows)
1. If you are running behind a proxy server make sure that you have set the `HTTP_PROXY`and `HTTPS_PROXY` environment variables according to your local proxy configuration.

   ```bash
   export http_proxy="http://proxy.example.com:80/"
   export https_proxy="https://proxy.example.com:443/"
   ```
