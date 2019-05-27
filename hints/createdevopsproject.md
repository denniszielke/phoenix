# Create an Azure DevOps Project
1. In Azure Portal create a new DevOps project (Click "create a resource", then search for DevOps)
1. Select Node.js as language
1. Select Simple Node.js App
1. Select Kubernetes Service as deployment target
 
1. In the final dialog chose a name for your project and pick your DevOps Org. If you don't have a DevOps Org yet, click Additional Settings and specify a name for it. If you already have one, you can chose this one.
1. Select to create a new AKS cluster.
1. As location choose North Europe everywhere (also for AppInsights, Log location and Registry in additional Settings)
1. It should look like this:
![](/hints/images/devopsproject1.jpg)

1. After this you have
- a DevOps organization 
- a build & release pipeline
- demo source code for a node.js app
1. The build will kick off automatically. During the build a Container Registry will be created. During release the AKS cluster will be created.

After cluster creation set up your work environment (or bash) to enable cluster access. See the hints at the lower part of this file [here :blue_book:](create_aks_cluster.md)! 