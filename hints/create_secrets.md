# Create Azure Container Registry secret in Kubernetes

> **Important:** This is only required if you are not using an azure container registry that is part of the same subscription
>
> Preferred approach is to grant the Kubernetes service principal Reader role permissions in your azure container registry via Access Control (IAM

```bash
kubectl create secret docker-registry kuberegistry \
  --docker-server 'myveryownregistry-on.azurecr.io' \
  --docker-username 'username' \
  --docker-password 'password' \
  --docker-email 'example@example.com'
```

or

```bash
kubectl create secret docker-registry kuberegistry
  --docker-server $REGISTRY_URL \
  --docker-username $REGISTRY_NAME \
  --docker-password $REGISTRY_PASSWORD \
  --docker-email 'example@example.com'
```

> **Hint:** In case of problems pulling your images, try creating the secret without '' around the values.

# Deploy additional secrets

https://kubernetes.io/docs/concepts/configuration/secret/

Simple way to deploy secrets via command line

```bash
kubectl create secret generic mySecretName --from-literal=username=someRandomSecretValue
```

OR do it via yaml files - here secrets must be base64 encoded.

```bash
echo -n "someRandomSecretValue" | base64
```

To create an application insights secret required for the calculator enter the following with the correct key

```bash
kubectl create secret generic appinsightsecret --from-literal=appinsightskey=ab0bebe0-7e34-4ed3-b943-6fa683730a55
```

Define secret in yaml file

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mySecretName
type: Opaque
data:
  username: c29tZVJhbmRvbVNlY3JldFZhbHVl
```

Deploy secret to cluster

```bash
kubectl create -f secrets.yml
```

Deploy secret for redis

```bash
REDIS_HOST=sadasdf.redis.azure.com
REDIS_AUTH=HereBeAuthKEy

kubectl create secret generic rediscachesecret \
  --from-literal=redishostkey=$REDIS_HOST \
  --from-literal=redisauthkey=$REDIS_AUTH
```

# Reference a secret from an environment variable

Assuming you have deployed your secret to your cluster you can now reference your secret during deployments and set the value of a secret to an environment variable like this:

```yaml
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
