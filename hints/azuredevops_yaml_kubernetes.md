# Azure devops deployment via yaml

## Create yaml file
1. Create a `azureFullDeploymentToK8s.yaml` file which contains a section for a service and a section for a deployment separted by `------`.
2. You can find a sample for a service description in yaml [here](https://kubernetes.io/docs/concepts/services-networking/service/) .
3. You can find a sample for a deployment description in yaml [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
4. Modify the sections to represent the backend service. 
5. Apply the yaml file `kubectl apply -f filename`. Make sure you delete all resources you want to recreate to avoid confuision. (`kubectl delete...`)

## Include the yaml with your build pipeline
1. If everything worked as expexted, modify the image section to target a placeholder `latest` or  `#{Build.BuildNumber}#` instead of a specific version. Check in your yaml file into your repo.
2. For automation create a build pipeline in azure devops (use the same you already have for your container builds)
3. Add a build artifact in the pipeline. 
4. Save and queue a build.
![](/hints/images/azuredevops_drop_artifact.png)

## Deploy the yaml via release pipeline
1. Create a new release pipeline.
![](/hints/images/azuredevops_release_pipeline.png)
2. Make sure that you are carrying over the artifacts from build pipeline. If you need to release a specific version you need to modify the yaml file and replace your token with the current build id.
3. Add a Kubernetes apply task to your pipeline. Make sure that the version of the task is set to `1.*`
4. Authorize the service connection - if you to not have enough permissions on your azure subscription use the fallback by creating a `Kubernetes Service Connection`  [here :blue_book:](azuredevops_service_connection.md)!
5. Select command `apply` and check the `use configuration files` option to select and apply the yaml file from your build.
```
$(System.DefaultWorkingDirectory)/_phoenix_ws-aci-helloworld/drop/aci-helloworld.yaml
```
![](/hints/images/azuredevops_release_aks.png)
6. Trigger the release
