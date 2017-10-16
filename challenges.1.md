# Single Container Loop Challenge
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


