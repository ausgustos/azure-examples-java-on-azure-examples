#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION
export ARO_NAME=aro-$RANDOM

az network vnet create \
--resource-group $RESOURCE_GROUP \
--name aro-vnet \
--address-prefixes 10.0.0.0/22

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name aro-vnet \
--name aro-master-subnet \
--address-prefixes 10.0.0.0/23 \
--service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name aro-vnet \
--name aro-worker-subnet \
--address-prefixes 10.0.2.0/23 \
--service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update \
--name aro-master-subnet \
--resource-group $RESOURCE_GROUP \
--vnet-name aro-vnet \
--disable-private-link-service-network-policies true

az aro create \
--name $ARO_NAME \
--resource-group $RESOURCE_GROUP \
--master-subnet aro-master-subnet \
--worker-subnet aro-worker-subnet \
--vnet aro-vnet

export RESULT=$(az aro show --name $ARO_NAME --resource-group $RESOURCE_GROUP --output tsv --query provisioningState)
az group delete --name $RESOURCE_GROUP --yes || true
if [[ "$RESULT" != Succeeded ]]; then
echo "Azure RedHat OpenShift cluster " $ARO_NAME " was not created successfully"
exit 1
fi