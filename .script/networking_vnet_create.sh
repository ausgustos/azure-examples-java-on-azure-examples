#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION
export VNET=myvnet
az network vnet create \
--name $VNET \
--resource-group $RESOURCE_GROUP \
--subnet-name default

export RESULT=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET --query provisioningState --output tsv)
az group delete --name $RESOURCE_GROUP --yes || true
if [[ "$RESULT" != Succeeded ]]; then
exit 1
fi
exit 0