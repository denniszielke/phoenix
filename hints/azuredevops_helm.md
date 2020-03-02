# Package and release your helm chart using azure devops

If you to not have enough permissions on your azure subscription use the fallback by creating a `Kubernetes Service Connection`  [here :blue_book:](azuredevops_service_connection.md)!

> Make sure to check for the current helm version (should be version 3) via azure shell:
```
helm version
```

## Create build pipeline for packaging helm charts
1. Create a build pipeline - you can clone an existing pipeline - make sure it includes all your containers.
2. Add an `Install Helm` task. Make sure that you have the latest helm version (3.0.2) and kubectl version (1.16.0).
3. Add two `Package and deploy Helm charts` task to your pipeline and set the connection to your Kubernetes cluster.
4. Modify the second helm task command to `package`. Leave the destination to `$(Build.ArtifactStagingDirectory)`.
5. Add a `Publish artifact` task to carry over the helm chart to your staging directory.

![](/hints/images/azuredevops_package_helm.png)

### Bonus: Publish your helm chart to your azure container registry
![](/hints/images/azuredevopshelm.png)

## Create a release pipeline for your packaged helm charts
1. Create release pipeline - there is a template for helm release pipelines.
2. Add the artifacts from your previous build pipeline.
3. Adjust the helm and kubectl version of your `Install Helm` task.
4. Modify the `upgrade` task to your pipeline and set the connection to your Kubernetes cluster.
5. Set the upgrade task to load the chart from your packaged helm chart. It makes sense to adjust it to use a wildcard to ensure versioning support
```
$(System.DefaultWorkingDirectory)/_phoenix_ws-aci-helloworld-helm/chart/multicalculator-*.tgz
```
6. It is recommended to always deploy into a namespace and give the release a unique name. In this case we use the buildid for this
```
calc
```
7. You should at lease override the image tags with your build version in the arguments.
```
--set image.frontendTag=$(Build.BuildId) --set image.backendTag=$(Build.BuildId)
```
If you are using images from your own registry you should override image.repository argument
```
--set image.repository=yourownregistry.azurecr.io
```
8. Set the force tag to override eventual errors

![](/hints/images/azuredevops_release_helm.png)
