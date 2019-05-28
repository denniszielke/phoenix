# Kubernetes yaml file deployments

## Yaml file definition

https://kubernetes.io/docs/user-guide/walkthrough/

The simplest pod definition describes the deployment of a single container. For example, an nginx web server pod might be defined as such:

```yaml
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

```yaml
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

To allow for authentication to your azrue container registry make sure that your kubernetes service principal has at least **_Reader_** permissions on your container registry:
https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/container-registry/container-registry-auth-aks.md

```yaml
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
