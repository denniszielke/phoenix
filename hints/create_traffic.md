# Create traffic

## Create a pod that you can log into

1. Create a pod that can host some command line tools
```
cat <<EOF | kubectl create -f -
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

2. Log into that pod
```
kubectl exec -ti centos -- /bin/bash
```

3. Run a query against a service from the inside
```
for i in {1..10000}; do curl -s -w "%{time_total}\n" -o /dev/null http://nameofyourservice; done
```

4. Cleanup of your pod
```
kubectl delete pod centos
```

## Configure a horizontal pod autoscaler
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

Select a deployment
```
kubectl autoscale deployment nginx --cpu-percent=20 --min=1 --max=8
```

## Look up performance metrics in azure container monitor
https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-analyze
