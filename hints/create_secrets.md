# Create Azure Container Registry secret in Kubernetes

!!! This is only required if you are not using an azure container registry that is part of the same subscription
!!! Prefered approach is to grant the Kubernetes service principal Reader role permissions in your azure container registry via Access Control (IAM)
See [learning yaml](learn_yaml_files.md).

```
kubectl create secret docker-registry kuberegistry --docker-server 'myveryownregistry-on.azurecr.io' --docker-username 'username' --docker-password 'password' --docker-email 'example@example.com'

```

or

```
kubectl create secret docker-registry kuberegistry --docker-server $REGISTRY_URL --docker-username $REGISTRY_NAME --docker-password $REGISTRY_PASSWORD --docker-email 'example@example.com'
```

Hint: In case of problems pulling your images, try creating the secret without '' around the values.

# Deploying additional secrets
https://kubernetes.io/docs/concepts/configuration/secret/

Simple way to deploy secrets via command line
```
kubectl create secret generic mysecretvalue --from-literal=username=someRandomSecretValue --from-literal=password=someRandomSecretPassword
```
OR do it via yaml files  - here secrets must be base64 encoded.
~~~
echo -n "someRandomSecretValue" | base64
~~~

To create an application insights secret required for the calculator enter the following with the correct key
~~~
kubectl create secret generic appinsightsecret --from-literal=appinsightskey=8e9a2af3-8a55-44e0-99bc-4ecd1f3ae59f
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

Deploy secret for redis
```
REDIS_HOST=sadasdf.redis.azure.com
REDIS_AUTH=HereBeAuthKEy
kubectl create secret generic rediscachesecret --from-literal=redishostkey=$REDIS_HOST --from-literal=redisauthkey=$REDIS_AUTH

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
