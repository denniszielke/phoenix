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
  username: MWYyZDFlMmU2N2Rm
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
