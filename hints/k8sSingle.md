# Single Container app in K8s

**Hint: You have to install kubectl first!**

1. Run single container app in your K8s cluster
```
kubectl create nginx --image=nginx
```
2. See what you got
```
kubectl get pods
```
3. Wrap your pod into a service 
```
kubectl expose deployment nginx --port=80
```
4. See what you got
```
kubectl get service
```
5. Edit your service to be able to be accessed from the public internet
```
kubectl edit service/nginx
```
6. This opens up an editor. Exchange ClusterIp to LoadBalancer. Close and save the file.
7. Check the state of your service
```
kubectl get service
```
8. Wait until your Service got a public address. Then type this address into your webbrowser.