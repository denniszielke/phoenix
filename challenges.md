## 0. Create Resources
Creating resources on Azure:
- Service Principal
- Resource Group
- Ubuntu VM for building and tagging

 > Need help? Check hints [here :blue_book:](hints/creatingresources.md)! 

# Single Container Loop 
In this chapter you will get a basic experience in working with containers. For this chapter we concentrate on single container applications running locally first and in Azure Container Instances in the second step.


## 1. Containerize your app 
- Get the code of the hello world application locally and navigate to the folder (phoenix\apps\aci-helloworld).
- Create a container image locally (you need docker running on your machine).
    ```
    docker build -t helloworld .
    ```
- Run the image in a container locally on your machine. Remember to open up the correct port in your command (-p).
    ```
    docker run -p 8080:80 helloworld
    ```
- Open the browser and navigate to the application you just started with your browser (http://localhost:8080). 

## 2. Automate your build 
> Need help? Check hints [here :blue_book:](hints/TeamServicesContainerBuild.md)!
- Import the sample code from to your VSTS Team Project. You can do this via UI. 
- Use VSTS to create a build definition which triggers on code changes. The build definition should 
    - create a new container image     
    - use the build number as tag to identify your image. The buildnumber can be found in variable *$(Build.BuildNumber)* 
    - push the new image to your private Azure Container Registry (if you don't have an ACR, create one first)

## 3. Release to ACI manually
> Need help? Check hints [here :blue_book:](hints/ManualReleaseToACI.md)!
- Run your newly created image in Azure Container Instances to see if everything works. You can start it manually in the portal or via command line.


## 4. Relase to ACI via VSTS
> Need help? Check hints [here :blue_book:](hints/TeamServicesToACI.md)!
- Use VSTS to create a release definition which is triggered by your build definition. This release definition should
    - deploy the latest image created by your build definition to ACI. Use the Azure CLI 
    task.
- Now you have a full end to end flow for single container applications.


# Kubernetes 101 
In this chapter you will set up a Kubernetes cluster in Azure Container Services (ACS) and an Azure Container Registry (ACR) to store your images.

## 1. Create a Kubernetes cluster on Azure Container Services 
- Set up your Kuberenetes cluster using Azure Container Services.
> Need help? Check hints [here :blue_book:](hints/createk8scluster.md)!

The deployment will take some time (~20 min). 

## 1. Run single container app in your K8s cluster
> Need help? Check hints [here :blue_book:](hints/k8sSingle.md)!
- Run a public available application in a single container on your cluster. The image name is "nginx".
    - Use the "kubectl run" command
- Add a service to make your application accessible from the internet
    - Use the "kubectl expose" command and "kubectl edit YOURSERVICE" command.
- Start your webbrowser to view your application running in your cluster.

## 1. Kubernetes discovery
- Open the K8s portal for a graphical interface. Run `kubectl proxy`then open up a browser an navigate to http://localhost:8001/ui.

- Familiarize yourself with the following commands on commandline, eg.
```
kubectl get pods    // to display all pods
kubectl get svc     // to display all services
kubectl get deployments     // to display all deployments
kubectl delete pods/<podid> // to delete a specific pod

```

# Kubernetes Multicontainer 
> Need help? Check hints [here :blue_book:](hints/k8sMulti.md)!
In this chapter you will create a multi-container appliation in Kubernetes. 
## 1. Kubernetes multi container app deployment 
- Get the sample code for a multi container application. (Multi-Calc)
- Build the container images for frontend and backend services locally.
- Push the images to your ACR 
- Apply the container images in your Kubernetes cluster using the *.yml files provided 
    - calcbackend-pod.yml
    - calcbackend-svc.yml
    - calcfrontend-pod.yml
    - calcfrontend-svc.yml
- Configure your application to be accessible from the internet and call the page. Use the calculation.

## 2. AI **TODO**

**TODO AI**

## 3. Manual deployment via ReplicationController 

Let's see what happens if one of your pods fails.
- Delete the frontend pod using the commandline and call the website again. 
- You'll recognize that it will no longer work.
Let's configure it for self-healing.
> Need help? Check hints [here :blue_book:](hints/AddReplicationController.md)!
- Create a new yaml file **replicator.yml** and configure it to take care of replication of your application frontend pods. Set the number of replicas to 2.
    You can find a sample of an replication controller [here](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/). Try to find the correct values to run your frontend replicated.
- Apply the replication controller yaml file *replicator.yml*.
- This will take care of starting new instances whenever one of your pods fails. Try to kill the application again by deleting frontend pods and see if your website stays responsive.



# Fully automated VSTS YAML deployment
In this chapter you will leverage self-healing capabilites of K8s and extend your VSTS pipeline to trigger a deployment to your K8s cluster. Your application will have no downtime during a rolling upgrade.
 Need help? Check hints [here :blue_book:](hints/TeamServicesToK8s.md)!

## 1. Create a yaml
    - Create a deployment file to decribe the desired state of your application including replicas of your backend service.
    - Modify the deployment file manually so that 
        - the backend service can be found
        - the backend service is available internally only
        - the correct image is being used
    - Apply the deployment file manually.

## 2. Fake a failed pod
    - Check the number of backend pods. K8s will take care to keep the number of available pods as specified.
    - Give it a try and kill some pods. They will be recreated.

## 3. Automate zero downtime deployment via VSTS
    - Now let's automate all of this. Create a VSTS release definition. Make sure it
    - triggers when the build has finished
    - deploy your latest image created by the build definition with help of the deployment.yaml file. You can use the Azure CLI task to do this.
    - Use $(Build.BuildNumber) to apply the correct image.
    





​
