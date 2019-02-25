# Create an ACR task which fires when your Github repo changes
1. Fork the phoenix project to your own github account
1. Create an ACR task 
```
az acr task create --registry $ACR_NAME --name taskhelloworld --image phoenixautohelloworld:{{.Run.ID}} --context https://github.com/$USER/phoenix.git  --branch master --file apps/aci-helloworld/ACR.Dockerfile     --git-access-token $GITHUBTOKEN
```

1. Modify code in your Github repo
1. Check if the task has been created. (az acr task list -g $RESOURCEGROUP -r $ACR_NAME)
1. Check if the task fired (az acr task run -g $RESOURCEGROUP -r $ACR_NAME -n taskhelloworld) 
1. Check in the registry if you can find the new image
