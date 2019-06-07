# Use azure devops to create a container build pipeline

1. Create a new azure devops project by going on https://dev.azure.com/ 

2. Import the sample code from to your azure devops team project. You can do this via UI in the Repos tab of your team project.
![](images/azuredevops_import_project.png)

3. Create a new pipeline to build containers and use the **docker container** template.
![](images/azuredevops_new_pipeline.png)

4. Choose "Hosted Linux Preview" as build agent queue and make sure your pipeline has a propper name.
![](images/azuredevops_import_project.png)

5. Add the following tasks for your pipeline phase (if you don't find them you can search or install from the marketplace)

> If you have issues with authentication to your azure container registry - you can create use the docker registry type  [here :blue_book:](azuredevops_service_connection.md)!

- Use $(Build.DefinitionName):$(Build.BuildId) to name your image automatically in a format that will allow you find it later. 
- Make sure you reference your Dockerfile correctly
- On the first pipeline you have to authorize your pipeline for your azure subscription.
- Make sure there is always a latest tag on your images

    - "Docker" task to create a container image

![](images/vstsbuild.png)
    - "Docker" task to push the image
    
![](images/vstshelloworldpushimage.jpg)

6. Start the pipeline and check your container registry for the new image
