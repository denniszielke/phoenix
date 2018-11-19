# Azure Devops to K8s
1. Create a `azureFullDeploymentToK8s.yaml` file which contains a section for a service and a section for a deployment separted by `------`.
1. You can find a sample for a service description in yaml [here](https://kubernetes.io/docs/concepts/services-networking/service/) .
1. You can find a sample for a deployment description in yaml [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
1. Modify the sections to represent the backend service. 
1. Apply the yaml file `kubectl apply -f filename`. Make sure you delete all resources you want to recreate to avoid confuision. (`kubectl delete...`)
1. If everything worked as expexted, modify the image section to target a placeholder #{Build.BuildNumber}# instead of a specific version.
1. For automation create a release definition in azure devops.
1. Add a build artifact in the pipeline. Choose your build defintion from the previous steps. 
1. Make sure your **build** definition contains a step to publish your yaml file. (You might have to add it to source control first)
1. Add a task in your release to replace tokens.
1. Add a task to apply the yaml file.
1. Now if you run a build a release will be triggered and the latest image will be autodeployed with zero downtime.

