# Single Container Loop Challenge
## Why
Containers can make certain aspects of a developer's or admin's life very easy by hiding complexity and by providing reliability.
In this chapter you will get a basic experience in working with containers. For this chapter we concentrate on single container applications running locally first and in Azure Container Instances in the second step.

![](/img/challenge1.png)

## Here's what you'll learn: ##
- Container basics
    - Get a feeling for work with containers and understand their purpose
    - Understand what a Dockerfile is
    - How to create a container image
    - How to run a container image locally
    - Get a sense for container networking and ports
    - How to create new versions of images
    - Learn about tagging
    - How to use azure devops or github actions automation to set up an automated workflow
- Deployment
    - How to provide a container image in a registry 
    - How to set up a container registry
    - How to run a container in the cloud


## 1. Containerize your app 
> This is about putting your apps inside a container
- Get the code of the hello world application 
    ``` 
    git clone https://github.com/denniszielke/phoenix
    ```

### A. Create a container remotely (using azure container registry builds) 
https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-tutorial-quick-task 
- Go to azure shell (https://shell.azure.com)

- Clone the repository 
```
git clone https://github.com/denniszielke/phoenix
```
- Go the the aci-hello world app folder
```
cd phoenix/apps/aci-helloworld/
```
- Open up vs code in your cloud shell
```
code .
```
- Trigger your azure container registry to build your container remotely
```
ACR_NAME=$( az acr list --query "[].{Name:name}" -o tsv )
az configure --defaults acr=$ACR_NAME
az acr build --image helloacrtasks:v1 .
```
- Verify the results in your container registry.
![](/img/acr-remote-build.png)

### B. Create a container automatically using github actions
Check out github actions: https://github.com/features/actions

We recommend this github action for azure container registry: https://github.com/Azure/docker-login

- Fork the phoenix repository to your own github account

- Configure your azure container registry to use the admin account

- Configure the values for ACR_NAME (take the loginserver name of your ACR), ACR_USERNAME and ACR_PASSWORD (take a password from the access keys) as github secrets for your project

- Use this sample https://raw.githubusercontent.com/denniszielke/phoenix/master/.github/workflows/build-acr-aci-helloworld.yml and configure it as a github 

- Run the github action and check that it will build, push and tag your container to your azure container registry

![](/img/githubactions.png)

### C. Create a container locally (as last resort)
- Create a container image locally (you need docker running on your machine). Don't forget the trailing "." in the following line!
    ```
    docker build -t helloworld .
    ```
- Check if the image has been built.
    ```
    docker images
    ```
- Run the image in a container locally on your machine. Remember to open up the correct port in your command (-p).
    ```
    docker run -d -p 8080:80 helloworld
    ```
- Open the browser and navigate to the application you just started with your browser (http://localhost:8080). If you're running on a Linux VM in Azure, just run this command to avoid working with a graphical browser:
    ```
    wget http://localhost:8080
    ```
    Then check the content with:
    ```
    cat index.html
    ```
- Check the running processes
```
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
bc4b6b155c2c        helloworld          "/bin/sh -c 'node /u…"   12 seconds ago      Up 9 seconds        0.0.0.0:8080->8080/tcp   peaceful_mccarthy
```
- Kill the process to clean up
```
docker kill bc4b6b155c2c
```
- Push your image to your registry

## 2. Start your container in azure container instances
> This is about checking that your container actually works outside of your dev environment. 
> Need help? Check hints [here :blue_book:](hints/deploy_to_aci.md)!
- Run your newly created image in Azure Container Instances to see if everything works. You can start it manually in the portal or via command line.

    
## Bonus Challenge 1 - Automate your build using ACR tasks based on Github commits
> Need help? Check hints [here :blue_book:](https://github.com/denniszielke/phoenix/blob/master/hints/acr_task_github_trigger.md)!
- Create an ACR Tasks which triggers whenever you update your Github repo.

## Bonus Challenge 2 . Automate the build of your container in azure devops
> This is about automating the build of your container outside of your dev environment.
> Need help? Check hints [here :blue_book:](hints/automate_container_build.md)!
- Import the sample code from to your azure devops project. You can do this via UI. 
- Use azure devops to create a build definition which triggers on code changes. The build definition should 
    - create a new container image     
    - use the build number as tag to identify your image. The buildId can be found in variable *$(Build.BuildId)*  (The screenshots may show Buildnumber - make sure to use the BuildId)
    - push the new image to your private Azure Container Registry (if you don't have an ACR, create one first)
