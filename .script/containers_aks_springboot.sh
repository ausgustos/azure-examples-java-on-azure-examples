#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION

if [[ -z $AKS ]]; then
export AKS=aks-$RANDOM
az aks create --name $AKS --resource-group $RESOURCE_GROUP --generate-ssh-keys --verbose
fi


cd containers/aks/create-kube-config

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS --admin --file config
export KUBECONFIG=$PWD/config

cd ../../..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION

if [[ -z $AKS ]]; then
export AKS=aks-$RANDOM
az aks create --name $AKS --resource-group $RESOURCE_GROUP --generate-ssh-keys --verbose
fi


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION
if [[ -z $ACR_NAME ]]; then
export ACR_NAME=acreg$RANDOM
fi
az acr create \
--name $ACR_NAME \
--resource-group $RESOURCE_GROUP \
--sku Basic \
--admin-enabled true
az aks update --name $AKS --resource-group $RESOURCE_GROUP --attach-acr $ACR_NAME

cd containers/aks/springboot

mvn package
az acr build --registry $ACR_NAME --image springboot:latest .
sed -i "s/ACR/$ACR_NAME/g" deployment.yml
kubectl apply -f deployment.yml

sleep 240

export URL=http://$(kubectl get service/springboot --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
export RESULT=$(curl $URL)

az group delete --name $RESOURCE_GROUP --yes || true

if [[ "$RESULT" != *"Hello World"* ]]; then
echo "Response did not contain 'Hello World'"
exit 1
fi


cd ../../..