# GitOps challenge
> Need help? Check hints [here :blue_book:](hints/flux.md)! 

## Why
If you using a CI/CD pipeline to push changes in your environments while at the same time other people or tools perform changes to your applications this increases the chance of config drift. Another possible approach is to use your source control as your central system of records and enforce this by building a process around this. The basic idea is that you are using a pod inside your cluster to continously watch for your desired state in your git repo and reconsile your cluster state with your git repo state if they drift apart.

![](/img/challenge6.png)

## Here's what you'll learn:
> - Leveraging GitOps to ensure the desired state of your environment
> - Using GitHub actions to build your helm chart and containers
> - Using flux to implement a GitOps flow

## 1. Deploy flux
- Deploy and configure flux
- Create another git repo for your yaml files

## 2. Automatically publish and configure your yaml files
- Create a new github action
- Package your helm chart either to your ACR https://github.com/helm/chart-releaser-action

## 3. Configure auth proxy
- Configure flux to watch for your config repo