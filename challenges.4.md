# Kubernetes Operational InsightsChallenge
> Need help? Check hints [here :blue_book:](hints/k8sMulti.md)!

## Why 
In this chapter you will upgrade your application to use another implementation of the calculator backend written in Go. You have heard that Go is so much faster and better and want to try this out without interrupting your users. Therefore you have to do a blue green deployment with your old frontend and backend along with your new go-calc-backend. All containers are sending telemetry to Application Insights (assuming you have configured the configuration of the insights key correctly) - so you should be able to evaluate the performance of your new container relative to the old one. If it does not improve your service you should perform a rollback - all without impacting your users.

![](/img/challenge4.png)

## Here's what you'll learn:
> - How to set up and configure ingress
> - Learn how Helm facilitates the deployment of complex container dependencies
> - How to gain insights into your application performance using Application Insights
> - How to rollback a deployment

## 1. Containerize the go-calc-backend
- Install and configure Go on your build machine
- Build a container
- Put it in your container registry

If you do not want to build the go backend you can use the already built image from docker hub:
https://hub.docker.com/r/denniszielke/go-calc-backend/
https://hub.docker.com/r/denniszielke/js-calc-frontend/
https://hub.docker.com/r/denniszielke/js-calc-backend/

## 2. Create a helm chart for your application
> This is about packaging your whole app
> Need help? Check hints [here :blue_book:](hints/helm.md)!

You will need to create:
- Create a deployment yaml file
- Create an helm chart
- Make sure that the environment variables for PORT and INSTRUMENTATIONKEY are set correctly
- Deploy your helm chart to your cluster manually

## 3. Deploy your helm chart via azure devops
> This is about continously deploying your app via azure devops
> Need help? Check hints [here :blue_book:](hints/azuredevops_helm.md)!

You will need to create:
- Checkin your helm chart into your repo
- Make sure that the environment variables for PORT and INSTRUMENTATIONKEY are set correctly
- Create a build pipeline so that it packages and versions your helm chart during build with your containers
- Create a release pipeline so that you deploy your helm chart automatically

## 4. Analyze and Improve the performance of your new backend
![](/img/appmap.jpg)
- Trigger a continuous look and generate sufficient telemetry data
- Use Application Insights to compare the performance
- Deploy a load/ availability test from azure to your ingress
- Use AKS health to check for performance and health of the containers and your cluster
- If the performance is not good enough perform a rollback

## BONUS Challenge 1 - Put your helm chart into an helm chart repository
https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-helm-repos
- Automatically publish your helm chart in your container registry
- Share the helm chart repo with your co-worker and see that the installation works from remote

## BONUS Challenge 2 - Use an azure redis cache to optimize performance
- Create an azure redis cache and set environment variables
```
REDIS_HOST=XXXXX.redis.cache.windows.net
REDIS_AUTH=ASDFASDFASDFASDF=
```
- Create a redis secret in the app namespaces
```
kubectl create secret generic rediscachesecret --from-literal=redishostkey=$REDIS_HOST --from-literal=redisauthkey=$REDIS_AUTH --namespace $APP_NS
```
- Configure the deploymet to use '--set dependencies.useRedis=true'