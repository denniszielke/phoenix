# Create a service connection for azure devops
Only use this if you do not have permissions on your azure subscription to use the automatic authentication between azure devops and your azure subscription


## Service connection for kubernetes

1. Create a kubernetes service connection with the following values

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