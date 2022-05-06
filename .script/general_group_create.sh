#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION

export RESULT=$(az group show --name $RESOURCE_GROUP --output tsv --query properties.provisioningState)
az group delete --name $RESOURCE_GROUP --yes || true
if [[ "$RESULT" != Succeeded ]]; then
exit 1
fi