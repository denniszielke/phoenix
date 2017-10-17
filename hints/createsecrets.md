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
echo -n "someRandomSecretValue" | base64
~~~

Define secret in yaml file
```
apiVersion: v1
kind: Secret
metadata:
  name: mySecretName
type: Opaque
data:
  username: c29tZVJhbmRvbVNlY3JldFZhbHVl
```

Deploy secret to cluster
```
kubectl create -f secrets.yml
```

# Referencing a secret from an environment variable

Assuming you have deployed your secret to your cluster you can now reference your secret during deployments and set the value of a secret to an environment variable like this:

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mySecretName
            key: mySecretLookUpKey
```
