#!/bin/bash
check_canary_slot () {
    DEPLOY_NAMESPACE=$1-$KUBERNETES_NAMESPACE
    RELEASE=$1-calculator
    echo -e "checking release $1 in $DEPLOY_NAMESPACE ..."
    helm get values $RELEASE -n $DEPLOY_NAMESPACE -o table
    CANARY=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.ingress.canary' -r)
    if [ "$CANARY" == "true" ]; then 
        CANARY_SLOT=$(helm get values $RELEASE -n $DEPLOY_NAMESPACE -o json | jq '.slot' -r)
        if [ "$CANARY_SLOT" == "blue" ]; then 
            PRODUCTION_SLOT="green"
        elif [ "$CANARY_SLOT" == "green" ]; then
            PRODUCTION_SLOT="blue"
        fi
        echo -e "Found $CANARY_SLOT canary release in $1"
    else 
        echo -e "Found no canary release in $1"
    fi 
}

echo "Starting failure cleanup"
echo "AGENT_WORKFOLDER is $AGENT_WORKFOLDER"
echo "AGENT_WORKFOLDER contents:"
ls -1 $AGENT_WORKFOLDER
echo "SYSTEM_HOSTTYPE is $SYSTEM_HOSTTYPE"
echo "Build Id is $BUILD_BUILDNUMBER and $BUILD_BUILDID"
echo "Azure Container Registry is $AZURE_CONTAINER_REGISTRY_NAME"
AZURE_CONTAINER_REGISTRY_URL=$AZURE_CONTAINER_REGISTRY_NAME.azurecr.io
echo "Azure Container Registry Url is $AZURE_CONTAINER_REGISTRY_URL"
echo "Azure KeyVault is $AZURE_KEYVAULT_NAME"

KUBERNETES_NAMESPACE=$(az keyvault secret show --name "phoenix-namespace" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_NAME=$(az keyvault secret show --name "aks-name" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
AKS_GROUP=$(az keyvault secret show --name "aks-group" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)
INGRESS_FQDN=$(az keyvault secret show --name "phoenix-fqdn" --vault-name $AZURE_KEYVAULT_NAME --query value -o tsv)

echo "Authenticating with azure container registry..."
az acr login --name $AZURE_CONTAINER_REGISTRY_NAME
az configure --defaults acr=$AZURE_CONTAINER_REGISTRY_NAME
az acr helm repo add
helm repo update
#helm search repo -l $AZURE_CONTAINER_REGISTRY_NAME/multicalculatorcanary

echo "Pulling kube-config for $AKS_NAME in $AKS_GROUP"
az aks get-credentials --resource-group=$AKS_GROUP --name=$AKS_NAME

echo "waiting for 10 seconds to allow deployment to settle"
sleep 10
echo ""
echo "Checking production curl http://$INGRESS_FQDN/ping"
curl -s -H "canary: never" -H "Host: $INGRESS_FQDN" http://$INGRESS_FQDN/ping
echo ""
echo "Checking staging slot curl http://$INGRESS_FQDN/ping"
curl -s -H "canary: always" -H "Host: $INGRESS_FQDN" http://$INGRESS_FQDN/ping
echo ""
echo "Your app is publicly reachable under http://$INGRESS_FQDN"
echo ""

CANARY_SLOT="none"
PRODUCTION_SLOT="none"

check_canary_slot "blue"
check_canary_slot "green"

if [ "$CANARY_SLOT" != "none" ]; then 
echo "Looks good!"
echo "Canary $CANARY_SLOT will be promoted to production"
fi

if [ "$PRODUCTION_SLOT" != "none" ]; then 
echo "Looks good!"
echo "Production $PRODUCTION_SLOT will be deleted to production"
fi


