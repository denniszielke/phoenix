# Automatic creation of containers from source
There are two options

## A. Use azure devops to create a build pipeline


## B. Use azure container registry tasks (assuming you have a github account)
https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-tutorial-build-task

1. Get a git personal access token (for repo:status and repo:public_repo)
```
ACR_NAME=        # The name of your Azure container registry
GIT_USER=denniszielke      # Your GitHub user account name
GIT_PAT= # The PAT you generated in the previous section
````

2. Create acr task using your azure shell
```
az acr task create \
    --registry $ACR_NAME \
    --name js-calc-backend \
    --image js-calc-backend:{{.Run.ID}} \
    --context https://github.com/$GIT_USER/phoenix.git \
    --branch master \
    --file apps/js-calc-backend/Dockerfile \
    --git-access-token $GIT_PAT
```

3. Trigger the task
```
az acr task list --registry $ACR_NAME 
az acr task run --registry $ACR_NAME --name js-calc-backend
```

4. Change source code and trigger a build

5. Optionally delete the task
```
az acr task delete --registry $ACR_NAME \
    --name js-calc-backend
```