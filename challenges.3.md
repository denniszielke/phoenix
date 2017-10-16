# Kubernetes Multicontainer Challenge
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

## 2. AI
Need help? Check hints [here :blue_book:](hints/applicationinsights.md)!
In this chapter you will create an application insights resource for monitoring your application performance and health status.
- Create application insights in azure
- Configure your apps to inject the application insights key via environment variables
- Use a kubernetes secret to ensure consistency
- Set up an availability test for your endpoint
- Observe and query your application performance during deployments and rolling upgrades

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
- Also measure the responsiveness using Application Insights. 
    - Create a Application Instance on Azure as described [here](hints/applicationinsights.md) and get the instrumentation key
    - Provide the AI key as an environment variable to your pods as a secret as described [here](hints/createsecrets.md) .


# Fully automated VSTS YAML deployment
In this chapter you will leverage self-healing capabilites of K8s and extend your VSTS pipeline to trigger a deployment to your K8s cluster. Your application will have no downtime during a rolling upgrade.
> Need help? Check hints [here :blue_book:](hints/TeamServicesToK8s.md)!

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
