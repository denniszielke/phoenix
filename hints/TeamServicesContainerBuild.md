# Using Azure DevoOps to build & push a docker image to your Azure Container Registry

1. [Here](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal) is how you create an Azure Container Registry in the Azure portal if you don't have one yet.


2. Import the sample code from to your azure devops project. You can do this via UI in the Code tab of your Team Project.
![](images/import_code.jpg)

3. Create a new build definition you can do this in the Build & Release tab. Choose the submenu "Builds". Create an empty build definition.
![](images/newbuilddefinition.jpg)

4. Choose "Hosted Linux Preview" as build agent queue.

5. Add the following tasks for your build phase (if you don't find them you can search or install from the marketplace)
**Hint:** Use $(Build.DefinitionName):$(Build.BuildId) to name your image automatically in a format that will allow you find it later. 
**Hint:** Make sure you reference your Dockerfile correctly

    - "Docker" task to create a container image
    ![](images/vstsbuild.png)
    - "Docker" task to push the image
    ![](images/vstshelloworldpushimage.jpg)

6. Later you will need an additional step to move a "*.yaml" file to an artifacts folder. Use the "Publish Build Artifacts" Task. This will look like shown below.
**Hint:** Make sure you reference your yaml file from the correct location! 
![](images/vstsdropyaml.jpg)
