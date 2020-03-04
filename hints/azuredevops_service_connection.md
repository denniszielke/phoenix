# Create a service connection for azure devops
Only use this if you do not have permissions on your azure subscription to use the automatic authentication between azure devops and your azure subscription

Service Connections are beeing maintained in your Azure DevOps Project in the `Project Settings` under `Pipelines` under `Service connections` different connection types.

## Service connection for ARM

1. Create a new service connection of type `Azure Resource Manager` with Authentication method `Service principal (manual)`

If you not already have an azure devops service principal you can create one by running the following azure cli commands
```
DEPLOYMENT_NAME=dzphoenix

AZDO_SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --role="Contributor" --name $DEPLOYMENT_NAME-azdo -o json | jq -r '.appId')
AZDO_SERVICE_PRINCIPAL_SECRET=$(az ad app credential reset --id $AZDO_SERVICE_PRINCIPAL_ID -o json | jq '.password' -r)
AZDO_SERVICE_PRINCIPAL_OBJECTID=$(az ad sp show --id $AZDO_SERVICE_PRINCIPAL_ID -o json | jq '.objectId' -r)
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "You still need to assign permissions on AKS Keyvault, Azure Container Registry for your new service principal

echo "Your Azure DevOps service_principal_id should be $AZDO_SERVICE_PRINCIPAL_ID"
echo "Your Azure DevOps service_principal_secret should be $AZDO_SERVICE_PRINCIPAL_SECRET"
echo "Your Azure tenant_id should be $AZURE_TENANT_ID"
echo "Your Azure subscription_id should be $AZURE_SUBSCRIPTION_ID"
echo "Your Azure subscription_name should be $AZURE_SUBSCRIPTION_NAME"
echo "Your Azure DevOps Service Connection name should be defaultAzure"
```

1. Veryify that the connection works

## Service connection for kubernetes

1. Create a kubernetes service connection of type `Kubernetes` with the following values

a. Connection name = choose your name

b. Server Url = look up the api server address on your kubernets object
![](/hints/images/aks_api_server.png)
Add `https://` as a prefix

c. Retrieve the kubeconfig from your azure shell
```
cat ~/.kube/config
```
Copy the output into the KubeConfig field

2. Verify that the connection works

![](/hints/images/aks_service_connection.png)


## Service connection for azure container registry
If you cannot create a connection to your azure container registry, then swith the Container Registry Type dropdown to `Container Registry`.
You have to activate the Admin user under `Access keys` in your  azure container registry.

1. Create a new `Docker Registry Service Connection`
2. Select Registry Type `Other``
3. Give the connection a name so you can find it again
4. Set the value for Docker Registry to the Login Server Url of your container registry. Add `https://` as prefix
5. Use one of the two passwords from you azure container registry as password

![](/hints/images/acr_service_connection.png)