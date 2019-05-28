# Single Container Loop Challenge

## Why

Containers can make certain aspects of a developer's or admin's life very easy by hiding complexity and by providing reliability.
In this chapter you will get a basic experience in working with containers. For this chapter we concentrate on single container applications running locally first and in Azure Container Instances in the second step.

![](/img/challenge1.png)

---

## What you will learn

- Container basics
  - Get a feeling for work with containers and understand their purpose
  - Understand what a Dockerfile is
  - How to create a container image
  - How to run a container image locally
  - Get a sense for container networking and ports
  - How to create new versions of images
  - Learn about tagging
  - How to use Azure DevOps automation to set up an automated workflow
- Deployment
  - How to provide a container image in a registry
  - How to set up a container registry
  - How to run a container in the cloud

---

## 1. Containerize your app

> This is about putting your apps inside a container

- Get the code of the hello world application (_git clone https://github.com/denniszielke/phoenix_) locally and use the app in folder (phoenix\apps\aci-helloworld).

### A. Create a container remotely (without docker engine)

https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-tutorial-quick-task

- Go to Azure Shell (https://shell.azure.com)

- Clone the repository

  ```bash
  git clone https://github.com/denniszielke/phoenix
  ```

- Go the the `aci-helloworld` app folder

  ```bash
  cd phoenix/apps/aci-helloworld/
  ```

- Trigger your Azure Container Registry to build your container remotely

  ```bash
  ACR_NAME=
  az configure --defaults acr=$ACR_NAME
  az acr build --registry $ACR_NAME --image helloacrtasks:v1 .
  ```

- Verify the results in your container registry

  ![](/img/acr-remote-build.png)

### B. Create a container locally

- Create a container image locally (you need docker running on your machine). Don't forget the trailing `.` in the following line!

  ```bash
  docker build -t helloworld .
  ```

- Check if the image has been built.

  ```bash
  docker images
  ```

- Run the image in a container locally on your machine. Remember to open up the correct port in your command (`-p`).

  ```bash
  docker run -d -p 8080:80 helloworld
  ```

- Open the browser and navigate to the application you just started with your browser (http://localhost:8080). If you're running on a Linux VM in Azure, just run this command to avoid working with a graphical browser:

  ```bash
  wget http://localhost:8080
  ```

  Then check the content with:

  ```bash
  cat index.html
  ```

- Check the running processes

  ```bash
  docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
  bc4b6b155c2c        helloworld          "/bin/sh -c 'node /u…"   12 seconds ago      Up 9 seconds        0.0.0.0:8080->8080/tcp   peaceful_mccarthy
  ```

- Kill the process to clean up

  ```bash
  docker kill bc4b6b155c2c
  ```

- Push your image to your registry

## 2. Start your container in azure container instances

> This is about checking that your container actually works outside of your dev environment.
>
> Need help? Check hints [here :blue_book:](hints/deploy_to_aci.md)!

- Run your newly created image in Azure Container Instances to see if everything works. You can start it manually in the portal or via command line.

## Bonus Challenge 1 - Automate your build using ACR tasks based on Github commits

> Need help? Check hints [here :blue_book:](https://github.com/denniszielke/phoenix/blob/master/hints/acr_task_github_trigger.md)!

- Create an ACR Tasks which triggers whenever you update your Github repository.

## Bonus Challenge 2 - Automate the build of your container

> This is about automating the build of your container outside of your dev environment.
>
> Need help? Check hints [here :blue_book:](hints/automate_container_build.md)!

- Import the sample code from to your Azure DevOps project. You can do this via UI.
- Use Azure DevOps to create a build definition which triggers on code changes. The build definition should
  - create a new container image
  - use the build number as tag to identify your image. The Build ID can be found in variable `$(Build.BuildId)` (The screenshots may show `Buildnumber` - make sure to use the `BuildId`)
  - push the new image to your private Azure Container Registry (if you don't have an ACR, create one first)
