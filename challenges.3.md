# Kubernetes Multicontainer Challenge
> Need help? Check hints [here :blue_book:](hints/k8sMulti.md)!

> In this chapter you will create a multi-container appliation in Kubernetes. This is more close to real-life but makes administration a little more challenging. In reality you might want to be able to specify that mutliple containers are able to talk to each other in a defined way. You might want to make make sure certain parts of your application run in multiple instances to cover load. You might want to be able to monitor performance of your application. You might want to make sure that your system is self-healing so that faulty components are replaced automatically. For updates you might want to make sure to have zero downtime of your application. We are going to configure all of this in this section.

>## Here's what you'll learn:
>- How to write Yaml files to specify a desired state of a Kubernetes object
>- How to use the Azure Portal to view Application performance
>- How to store secrets in Kubernetes
>- How to configure your Kubernetes instance to ensure a certain number of pods is always running
>- How to define rolling upgrades to avoid downtime during an application update
>- How to put all what you've learned into an end to end azure devops pipeline


## 1. Kubernetes multi container app deployment yaml [here :blue_book:](hints/yaml/backend-pod.yaml)!
- Get the sample code for a multi container application. 
- Make sure that all source code has been built and the container images pushed to your registry.
- Create a deployment file to decribe the desired state of your application including replicas of your backend service.
- Modify the deployment file manually so that 
    - the backend service can be found
    - the backend service is available internally only
    - the correct image is being used. 
- Apply the deployment file manually.
- Configure your application to be accessible from the internet and call the page. Use the calculation.

## 2. Gaining insights by using application insights
> Need help? Check hints [here :blue_book:](hints/applicationinsights.md)!

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
> Need help? Check hints [here :blue_book:](hints/add_replication_controller.md)!
- Create a new yaml file **replicator.yml** and configure it to take care of replication of your application frontend pods. Set the number of replicas to 2.
    You can find a sample of an replication controller [here](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/). Try to find the correct values to run your frontend replicated.
- Apply the replication controller yaml file *replicator.yml*.
- This will take care of starting new instances whenever one of your pods fails. Try to kill the application again by deleting frontend pods and see if your website stays responsive.
- Also measure the responsiveness using Application Insights. 
    - Create a Application Instance on Azure as described [here](hints/applicationinsights.md) and get the instrumentation key
    - Provide the AI key as an environment variable to your pods as a secret as described [here](hints/create_secrets.md) .


# Fully automated azure devops deployment
In this chapter you will leverage self-healing capabilites of K8s and extend your azure devops pipeline to trigger a deployment to your K8s cluster. Your application will have no downtime during a rolling upgrade.
> Need help? Check hints [here :blue_book:](hints/TeamServicesToK8s.md)!

## 1. Create a yaml
- Create a deployment file to decribe the desired state of your application including replicas of your backend service.
- Modify the deployment file manually so that 
    - the backend service can be found
    - the backend service is available internally only
    - the correct image is being used. 
- Apply the deployment file manually.

## 2. Fake a failed pod
- Check the number of backend pods. K8s will take care to keep the number of available pods as specified.
- Give it a try and kill some pods. They will be recreated.

## 3. Automate zero downtime deployment via azure devops
- Now let's automate all of this. Create a azure devops release definition. Make sure it
- triggers when the build has finished
- deploy your latest image created by the build definition with help of the deployment.yaml file. You can use the Azure CLI task to do this.
- Use $(Build.BuildNumber) to apply the correct image.
    

# Bonus Challenge - Technology Shootout
Let's say a co-worker of you recommends writing the backend app with in "Go" for performance reasons. How could you try the Go-Backend and run it without downtime? Where could you find performance data? 
Implement the solution and upgrade your application to the Go-backend without downtime. (The Go backend app can be found in /apps/go-calc-backend .)
- Build the Go backend image 
- Publish the image in your registry
- Modify your backend-service Yaml to target the new image
- Deploy
- Check monitoring data for performance impact
- Use helm charts to deploy continous via azure devops hints [here :blue_book:](hints/TeamServicesHelmK8s.md)!



​
