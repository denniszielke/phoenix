
# Project Phoenix - Containerize your enterprize
Welcome to project Phoenix - a hands on workshop to practice container technology in the enterprise.

## What do we want to achieve?

After the workshop you should have hands on experience with:
1. Defining Application and system architectures for containers.
2. Defining, configuring up and maintaining runtime environments for containers in Azure.
3. Configuration options for CI/CD pipeline for containers in Azure.
4. Unterstanding of Kubernetes objects (Pods, Services, Deployments, Secrets) and their usage for multi container applications.
5. Logging, scaling and monitoring of container runtimes.

ACTIVATION OF AZURE PAAS: https://www.microsoftazurepass.com/

## How should the sample application look like?
![](/img/osba_multicalculator.png)

## Your path to there
1. [Set up](challenges.0.md) your system.
2. Accomplish the [Single Loop Challenge](challenges.1.md) and learn about container basics and Azure Container Instances for single container applications.
3. Do the [Kubernetes 101 Challenges](challenges.2.md) and learn about Kubernetes basic concepts (pods and services),deploy a container to your cluster and make it available in the internet.
4. Face [the Kubernetes Multicontainer Challenge](challenges.3.md) and deploy a complex multi container application update with zero downtime using an end to end automated azure devops pipeline.
5. Professionalize your operations using insights in the [Operations and Application Insights Challenge](challenges.4.md). Upgrade your application with another backend implementation written in Go, meassure the performance, reason about the performance metrics using Application Insights and if the new version is not good enough perform a rollback - without downtime.
6. Package your application and make use of the open service broker api to integrate your app into native Azure PaaS services by mastering the [Integration Challenge](challenges.5.md).
7. Secure your application for enterprise use case by using secure ingress, network policies, auth proxy and keyvault. [Security Challenge](challenges.6.md).
