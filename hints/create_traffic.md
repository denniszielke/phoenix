# Create traffic


## Configure a horizontal pod autoscaler
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

create a deployment
```
kubectl create deployment helloworld-app --image=denniszielke/aci-helloworld
kubectl expose deployment helloworld-app --type=LoadBalancer --port=80
kubectl autoscale deployment helloworld-app --cpu-percent=30 --min=1 --max=8
```

get the ip of the service
```
export PUBLIC_IP=$(kubectl get svc helloworld-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

## Trigger a load generator via aci

create resource group
```
az group create --name loadrunners --location westeurope
```

retrieve the endpoint that you want to post against (including path) 
```
PUBLIC_IP="x.x.x.x"
az container create --name myloadrunner --image denniszielke/load-generator --resource-group loadrunners --environment-variables GET_ENDPOINT=http://$PUBLIC_IP/ping
```

get the logs
```
az container logs --name myloadrunner --resource-group loadrunners
```

delete the resource group
```
az container delete --name myloadrunner --resource-group loadrunners
az group delete --name loadrunners --yes
```

## Create a pod that you can log into

1. Create a pod that can host some command line tools
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: centos
spec:
  containers:
  - name: centoss
    image: centos
    ports:
    - containerPort: 80
    command:
    - sleep
    - "3600"
EOF
```

or via
```
kubectl apply -f https://raw.githubusercontent.com/denniszielke/phoenix/master/hints/yaml/centos.yaml
```

2. Log into that pod
```
kubectl exec -ti centos -- /bin/bash
```

3. Run a query against a service from the inside
```
for i in {1..10000}; do curl -s -w "%{time_total}\n" -o /dev/null http://$PUBLIC_IP/ping; done
```

4. Cleanup of your pod
```
kubectl delete pod centos
```

## Generate load from local

```
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH
go get -u github.com/rakyll/hey
hey -z 20m http://$PUBLIC_IP/ping
```

## Look up performance metrics in azure container monitor
https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-analyze
