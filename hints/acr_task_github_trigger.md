# Create an ACR task which fires when your Github repo changes
1. Fork the phoenix project to your own github account
1. Get a Personal Token ( https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-build-task#create-a-github-personal-access-token )

1. Create an ACR task 
```
az acr task create --registry $ACR_NAME --name taskhelloworld --image phoenixautohelloworld:{{.Run.ID}} --context https://github.com/$USER/phoenix.git  --branch master --file apps/aci-helloworld/ACR.Dockerfile     --git-access-token $GITHUBTOKEN
```

1. Modify code in your Github repo
1. Check if the task has been created. 
```
az acr task list -g $RESOURCEGROUP -r $ACR_NAME
```

1. Check if the task fired 
```
az acr task run -g $RESOURCEGROUP -r $ACR_NAME -n taskhelloworld
```

1. Check in the registry if you can find the new image

# Manually build a container

Configure your cli to target your azure container registry
```
az configure --defaults acr=$ACR_NAME
```

Trigger a remote container build using your container registry `$ACR_NAME` to build the Dockerfile in your local folder to tag the container image with the name helloacr with the version v1
```
az acr build --registry $ACR_NAME --image helloacr:v1 .
```
