# Kubernetes yaml file deployments

## Yaml file definition
https://kubernetes.io/docs/user-guide/walkthrough/

The simplest pod definition describes the deployment of a single container. For example, an nginx web server pod might be defined as such:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
```

## liveness probes and variables
https://kubernetes-v1-4.github.io/docs/user-guide/liveness/

Ensure that health checks are performed against your instance

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  #namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
    env:       
      - name: "SOMEVARIABLE"
        value: "somevalue"
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      timeoutSeconds: 1
```

## Referencing images from your own registry

To allow for authentication to your azure container registry make sure that your kubernetes service principal has at least ***Reader*** permissions on your container registry:
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/container-registry/container-registry-auth-aks.md

For this to work first find out the ClientId of your cluster by listing all clusters and their clientids:
```
az aks list --query '[0].{Name:name, ClientId:servicePrincipalProfile.clientId}' -o table
```

Now retrieve the id of your azure container registry:
```
az acr list --query '[0].{Name:name, Id:id}' -o table
```

Now you assign your Kubernetes ClientId the permission to pull images from your registry by granting these permissions on the scope of your registry id:

```
REGISTRY_ID=
CLUSTER_CLIENT_ID=
az role assignment create --scope $REGISTRY_ID --role Reader --assignee $CLUSTER_CLIENT_ID
```

After this assignment has been done you can reference an image from your azure container registry using this sample yaml.

```
apiVersion: "v1"
kind: Pod
metadata:
  name: somePodName
  labels:
    name: someLabelName
spec:
  containers:
    - name: blue
      image: someRegistryOnAzure.azurecr.io/someImage:latest
      ports:
        - containerPort: 80
          protocol: TCP 
```
