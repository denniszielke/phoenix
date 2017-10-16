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

## Referencing images from your own registry

To reference an image from your own registry you need to reference a credential for the cluster to login. Check the hint about secrets: [here :blue_book:](createsecrets.md)

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
          name: http
          protocol: TCP 
  imagePullSecrets:
    - name: nameOfYourSecret

```
