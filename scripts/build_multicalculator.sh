#!/bin/bash

build_push_container () {
    echo "Starting to build container $1 ..."
    cd $BUILD_SOURCESDIRECTORY/apps/$1
    docker build -t $AZURE_CONTAINER_REGISTRY_URL/$1:$BUILD_BUILDNUMBER .
    echo "Completed building $1 container"
    docker push $AZURE_CONTAINER_REGISTRY_URL/$1:$BUILD_BUILDNUMBER
    echo "Completed pusing $1 container"
}

package_push_helmchart () {
    echo "Startig packaging helm chart $1 ..."
    cd $BUILD_SOURCESDIRECTORY/charts/
    helm package $1 --app-version 3.0.$BUILD_BUILDID --version 0.1.$BUILD_BUILDID
    echo "Pushing helm chart to $AZURE_CONTAINER_REGISTRY_NAME"
    az acr helm repo add
    az acr helm push $1-*.tgz --force
    echo "Pushed helm chart $1"
}

echo "Starting build"
echo "Argument is $1"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "AGENT_BUILDDIRECTORY is $AGENT_BUILDDIRECTORY"
echo "AGENT_BUILDDIRECTORY contents:"
ls -1 $AGENT_BUILDDIRECTORY
echo "SYSTEM_HOSTTYPE is $SYSTEM_HOSTTYPE"
echo "Build Id is $BUILD_BUILDNUMBER and $BUILD_BUILDID"
echo "Build Sources Folder is $BUILD_SOURCESDIRECTORY"
echo "Azure Container Registry is $AZURE_CONTAINER_REGISTRY_NAME"
AZURE_CONTAINER_REGISTRY_URL=$AZURE_CONTAINER_REGISTRY_NAME.azurecr.io
echo "Azure Container Registry Url is $AZURE_CONTAINER_REGISTRY_URL"
cd $BUILD_SOURCESDIRECTORY
ls -l
echo "Pushing images to $AZURE_CONTAINER_REGISTRY_URL"
az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
#build_push_container "go-calc-backend"
build_push_container "js-calc-backend"
build_push_container "js-calc-frontend"

package_push_helmchart "multicalculator"
