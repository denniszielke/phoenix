# Single Container app in Kubernetes

1. Run single container app in your K8s cluster

   ```bash
   kubectl run meinhelloworld --generator=run-pod/v1 --image=denniszielke/aci-helloworld
   ```

2. Alternative: run a container as part of a deployment

   ```bash
   kubectl create deployment hellworlds --image=denniszielke/aci-helloworld
   ```

   Scale the deployment to three

   ```bash
   kubectl scale deployment hellworlds --replicas=3
   ```

3. See what you got

   ```bash
   kubectl get pods
   ```

4. Wrap your pod into a service for an individual pod

   ```bash
   kubectl expose pod meinhelloworld --port=80 --name=hello-service
   ```

   Expose your deployment using a service

   ```bash
   kubectl expose deployment hellworlds --type=LoadBalancer --port=80
   ```

5. See what you got

   ```bash
   kubectl get service
   ```

6. Edit your service to be able to be accessed from the public internet

   ```bash
   kubectl edit service/hello-service
   ```

7. This opens up an editor. Exchange `ClusterIp` to `LoadBalancer`. Close and save the file. If you want to use nano instead of vi set the following environment variable

   ```bash
   KUBE_EDITOR="nano" kubectl edit svc/nginxpod-service
   ```

   > Shortcuts for vi:
   >
   > - `i` switches to insert mode
   > - `CRTL + C` switches to command mode
   > - `wq!` saves your changes and closes the file

8. Check the state of your service

   ```bash
   kubectl get service -w
   ```

9. Wait until your Service got a public address. Then type this address into your webbrowser.
