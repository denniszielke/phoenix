#!/bin/bash
echo "Starting build"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "AGENT_BUILDDIRECTORY is $AGENT_BUILDDIRECTORY"
echo "AGENT_BUILDDIRECTORY contents:"
ls -1 $AGENT_BUILDDIRECTORY
echo "SYSTEM_HOSTTYPE is $SYSTEM_HOSTTYPE"
echo "Build Id is $BUILD_BUILDNUMBER and $BUILD_BUILDID"
echo "Build Sources Folder is $BUILD_SOURCESDIRECTORY"
echo "Azure Container Registry is $AZURE_CONTAINER_REGISTRY"
AZURE_CONTAINER_REGISTRY_URL=$AZURE_CONTAINER_REGISTRY.azurecr.io
echo "Azure Container Registry Url is $AZURE_CONTAINER_REGISTRY_URL"
cd $BUILD_SOURCESDIRECTORY
ls -l
echo "Starting to build go-calc-backend container"
cd $BUILD_SOURCESDIRECTORY/apps/go-calc-backend
docker build -t $AZURE_CONTAINER_REGISTRY_URL/go-calc-backend:$BUILD_BUILDNUMBER .
echo "Completed building go-calc-backend container"
echo "Starting to build js-calc-backend container"
cd $BUILD_SOURCESDIRECTORY/apps/js-calc-backend
docker build -t $AZURE_CONTAINER_REGISTRY_URL/js-calc-backend:$BUILD_BUILDNUMBER .
echo "Completed building js-calc-backend container"
echo "Starting to build js-calc-frontend container"
cd $BUILD_SOURCESDIRECTORY/apps/js-calc-frontend
docker build -t $AZURE_CONTAINER_REGISTRY_URL/js-calc-frontend:$BUILD_BUILDNUMBER .
echo "Completed building js-calc-frontend container"

echo "Pushing images to $AZURE_CONTAINER_REGISTRY_URL"
az acr login --name $AZURE_CONTAINER_REGISTRY
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY
docker push $AZURE_CONTAINER_REGISTRY_URL/go-calc-backend:$BUILD_BUILDNUMBER
echo "Completed pusing go-calc-backend container"
docker push $AZURE_CONTAINER_REGISTRY_URL/js-calc-backend:$BUILD_BUILDNUMBER
echo "Completed pusing js-calc-backend container"
docker push $AZURE_CONTAINER_REGISTRY_URL/js-calc-frontend:$BUILD_BUILDNUMBER
echo "Completed pusing js-calc-frontend container"

echo "Startig packaging helm chart"
cd $BUILD_SOURCESDIRECTORY/charts/
helm package multicalculatorv3 --app-version 3.0.$BUILD_BUILDID
echo "Pushing helm chart to $AZURE_CONTAINER_REGISTRY"
az acr helm repo add
az acr helm push multicalculatorv3-*.tgz --force
echo "Pushed helm chart"
