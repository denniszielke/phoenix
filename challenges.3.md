# Kubernetes Multicontainer Challenge
> Need help? Check hints [here :blue_book:](hints/k8sMulti.md)!

## Why
In this chapter you will create a multi-container appliation in Kubernetes. This is more close to real-life but makes administration a little more challenging. In reality you might want to be able to specify that mutliple containers are able to talk to each other in a defined way. You might want to make make sure certain parts of your application run in multiple instances to cover load. You might want to be able to monitor performance of your application. You might want to make sure that your system is self-healing so that faulty components are replaced automatically. For updates you might want to make sure to have zero downtime of your application. We are going to configure all of this in this section.

![](/img/challenge3.png)

## Here's what you'll learn:
>- How to write Yaml files to specify a desired state of a Kubernetes object
>- How to use the Azure Portal to view Application performance
>- How to store secrets in Kubernetes
>- How to configure your Kubernetes instance to ensure a certain number of pods is always running
>- How to define rolling upgrades to avoid downtime during an application update
>- How to put all what you've learned into an end to end azure devops pipeline


## 1. Create Kubernetes multi container app deployment via yaml 
> This is about creating a desired state configuration for multiple apps
- For this sample we will deploy three different apps:
  - js-calc-frontend
  - js-calc-backend
  - go-calc-backend
- Get the source code for each app from [here](https://github.com/denniszielke/phoenix/tree/master/apps) (if you have not already cloned it in the first exercise). 
- Build the images for each app and push them to your container registry.
- Create a deployment yaml file to decribe the desired state of your application including replicas of your backend service.
- Construct the deployment yaml file manually so that 
    - the backend service can be found
    - the backend service is available internally only
    - the front end service is available from the internet
    - the correct image is being used
    - the upgrades happen using the rolling upgrade strategy
- Apply the deployment file manually using kubectl
- Get the public IP address and call the page of the frontend.

## 2. Automate yaml deployment via azure devops
> This is about automatically releasing your app via yaml to you cluster. [here :blue_book:](hints/azuredevops_yaml_kubernetes.md)!
- Check in your yaml file into your code repository
- Make sure that your yaml file is available in the drop
- Make sure to authenticate to your AKS cluster
- Use the kubernetes apply task in your release to deploy your app continously
- Activate the build and release trigger to deploy on every code change

## 3. Gaining insights by using application insights
> This is about understanding your application behaviour while you change code and deploy
> Need help? Check hints [here :blue_book:](hints/applicationinsights.md)!

In this chapter you will create an application insights resource for monitoring your application performance and health status.
- Create application insights in azure
- Configure your apps to inject the application insights key via environment variables
- Use a kubernetes secret to ensure consistency
- Set up an availability test for your endpoint
- Observe and query your application performance during deployments and rolling upgrades
    

## BONUS Challenge - Evaluating performance changes in your production
Let's say a co-worker of you recommends writing the backend app with in "Go" for performance reasons. How could you try the Go-Backend and run it without downtime? Where could you find performance data? 
Implement the solution and upgrade your application to the Go-backend without downtime. (The Go backend app can be found in /apps/go-calc-backend .)
- Build the Go backend image 
- Publish the image in your registry
- Modify your backend-service Yaml to target the new image
- Deploy
- Check monitoring data for performance impact
- Use helm charts to deploy continous via azure devops hints [here :blue_book:](hints/TeamServicesHelmK8s.md)!
