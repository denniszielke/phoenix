# Package and release your helm chart using Azure DevOps

If you to not have enough permissions on your azure subscription use the fallback by creating a `Kubernetes Service Connection` [here :blue_book:](azuredevops_service_connection.md)!

Make sure to check for the current helm version via azure shell:

```bash
helm version
```

## Create build pipeline for packaging helm charts

1. Create a build pipeline - you can clone an existing pipeline - make sure it includes all your containers.
1. Add an **Install Helm** task. Make sure that you have the latest helm version (2.12.0) and kubectl version (1.11.3).
1. Add two **Package and deploy Helm charts** task to your pipeline and set the connection to your Kubernetes cluster.
1. Modify the first helm task command to `init`. Set the arguments to `--client-only`
1. Modify the second helm task command to `package`. Leave the destination to `$(Build.ArtifactStagingDirectory)`.
1. Add a **Publish artifact** task to carry over the helm chart to your staging directory.

![](/hints/images/azuredevops_package_helm.png)

## Create a release pipeline for your packaged helm charts

1. Create release pipeline - there is a template for helm release pipelines.
1. Add the artifacts from your previous build pipeline.
1. Adjust the helm and kubectl version of your **Install Helm** task.
1. Modify the `init` and `upgrade` task to your pipeline and set the connection to your Kubernetes cluster.
1. Set the upgrade task to load the chart from your packaged helm chart. It makes sense to adjust it to use a wildcard to ensure versioning support

   ```bash
   $(System.DefaultWorkingDirectory)/_phoenix_ws-aci-helloworld-helm/chart/multicalchart-*.tgz
   ```

1. It is recommended to always deploy into a namespace and give the release a unique name. In this case we use the buildid for this

   ```
   calc
   ```

1. You should at lease override the image tags with your build version in the arguments.

   ```bash
   --set image.frontendTag=$(Build.BuildId) --set image.backendTag=$(Build.BuildId)
   ```

   If you are using images from your own registry you should override image.repository argument

   ```bash
   --set image.repository=yourownregistry.azurecr.io
   ```

1. Set the force tag to override eventual errors

![](/hints/images/azuredevops_release_helm.png)
