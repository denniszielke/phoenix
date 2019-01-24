# Single Container app in Kubernetes

**Hint:** You have to install kubectl first!**

1. Run single container app in your K8s cluster
```
kubectl run meinnginx --image=nginx
```
2. See what you got
```
kubectl get pods
```
3. Wrap your pod into a service 
```
kubectl expose deployment meinnginx --port=80 --name=nginx-service
```
4. See what you got
```
kubectl get service
```
5. Edit your service to be able to be accessed from the public internet
```
kubectl edit service/nginx-service
```
6. This opens up an editor. Exchange ClusterIp to LoadBalancer. Close and save the file.
Shortcuts for vi:
- `i` switches to insert mode
- `CRTL + C ` switches to command mode
- `wq!` saves your changes and closes the file

7. Check the state of your service
```
kubectl get service -w
```
8. Wait until your Service got a public address. Then type this address into your webbrowser.
