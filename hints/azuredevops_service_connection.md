# Create a service connection for Azure DevOps

Only use this if you do not have permissions on your azure subscription to use the automatic authentication between Azure DevOps and your azure subscription

## Service connection for kubernetes

1. Create a kubernetes service connection with the following values

   - **Connection name:** _choose your name_
   - **Server Url:** _choose your name_
   - **Server Url:** look up the api server address on your Kubernets object and add `https://` as a prefix

     ![](/hints/images/aks_api_server.png)

   - **KubeConfig:** Copy the outcome of the `cat ~/.kube/config` command from the Azure Shell

2. Verify that the connection works

   ![](/hints/images/aks_service_connection.png)

## Service connection for azure container registry

If you cannot create a connection to your azure container registry, then switch the Container Registry Type dropdown to `Container Registry`.
You have to activate the Admin user under `Access keys` in your azure container registry.

1. Create a new **Docker Registry Service Connection**
1. Select Registry Type **Other**
1. Give the connection a name so you can find it again
1. Set the value for Docker Registry to the Login Server Url of your container registry. Add `https://` as prefix
1. Use one of the two passwords from you azure container registry as password

![](/hints/images/acr_service_connection.png)
