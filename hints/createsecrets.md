# Create Azure Container Registry secret in Kubernetes
https://medium.com/devoops-and-universe/your-very-own-private-docker-registry-for-kubernetes-cluster-on-azure-acr-ed6c9efdeb51

```
kubectl create secret docker-registry kuberegistry --docker-server 'myveryownregistry-on.azurecr.io' --docker-username 'username' --docker-password 'password' --docker-email 'example@example.com'

```

or

```
kubectl create secret docker-registry kuberegistry --docker-server $REGISTRY_URL --docker-username $REGISTRY_NAME --docker-password $REGISTRY_PASSWORD --docker-email 'example@example.com'
```

# Deploying additional secrets
https://kubernetes.io/docs/concepts/configuration/secret/

Secrets must be base64 encoded.
~~~
echo -n "1f2d1e2e67df" | base64
~~~

Define secret in yaml file
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: 1f2d1e2e67df
```

Deploy secret to cluster
```
kubectl create -f secrets.yml
```