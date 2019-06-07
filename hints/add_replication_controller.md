# Create a Replication Controller
1. Create a file *replication.yml*
1. Start with a file like the one found [here](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)
1. Provide a name for your ReplicationController
1. Specify the correct replica set (in our sample 2)
1. Modify the template section of the file
    - point to the correct container image in your registry
    ```
     containers:

          - name: calcfrontend
            image: dzregistry.azurecr.io/calc/calc-frontend:latest
    ``` 
    - add information about the required ports for your container
    ```
            ports:
              - containerPort: 8080
                name: calcfrontend
                protocol: TCP
    ```
    - add all required environment variabes (ports, endpoints...) including the INSTRUMENTATIONKEY which gets the value from a secret which has been provided by you. Check hints for secrets [here]
    (createsecrets.md).
    ```env:       
              - name: "INSTRUMENTATIONKEY"
                valueFrom:
                  secretKeyRef:
                    name: appinsightsecret
                    key: appinsightskey              
    ```
    - provide the name for any required imagePullSecrets
    ```
        imagePullSecrets:
          - name: kuberegistry 
    ```
    
1. Then run 
```
kubectl apply -f replication yml
```
1. Now check 
```
kubectl get pods
```
1. You should see the number of pods specified in your Replica set.
1. Now kill one pod with 
```
kubectl delete pods/<IDOFPOD>
```
1. Check the number of pods again. you should see one pod termintating and anotherone is recreated instantly.
