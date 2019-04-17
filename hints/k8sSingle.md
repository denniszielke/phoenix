# Single Container app in Kubernetes


1. Run single container app in your K8s cluster
```
kubectl run meinhelloworld --generator=run-pod/v1 --image=denniszielke/aci-helloworld
```

2. Alternative: run a container as part of a deployment
```
kubectl create deployment hellworlds --image=denniszielke/aci-helloworld
```

Scale the deployment to three
```
kubectl scale deployment hellworlds --replicas=3
```

3. See what you got
```
kubectl get pods
```

4. Wrap your pod into a service for an individual pod
```
kubectl expose pod meinhelloworld --port=80 --name=hello-service
```

Expose your deployment using a service
```
kubectl expose deployment hellworlds --type=LoadBalancer --port=80
```

4. See what you got
```
kubectl get service
```

5. Edit your service to be able to be accessed from the public internet
```
kubectl edit service/hello-service
```

6. This opens up an editor. Exchange ClusterIp to LoadBalancer. Close and save the file.
If you want to use nano instead of vi set the following environment variable
```
KUBE_EDITOR="nano" kubectl edit svc/nginxpod-service
```

Shortcuts for vi:
- `i` switches to insert mode
- `CRTL + C ` switches to command mode
- `wq!` saves your changes and closes the file

7. Check the state of your service
```
kubectl get service -w
```

8. Wait until your Service got a public address. Then type this address into your webbrowser.
