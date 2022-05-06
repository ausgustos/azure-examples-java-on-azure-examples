#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION

if [[ -z $COSMOSDB_ACCOUNT_NAME ]]; then
export COSMOSDB_ACCOUNT_NAME=cosmosdb-$RANDOM
az cosmosdb create \
--name $COSMOSDB_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--locations regionName=eastus failoverPriority=0
fi


if [[ -z $COSMOSDB_SQL_DATABASE ]]; then
export COSMOSDB_SQL_DATABASE=sql-database-$RANDOM
az cosmosdb sql database create \
--resource-group $RESOURCE_GROUP \
--account-name $COSMOSDB_ACCOUNT_NAME \
--name $COSMOSDB_SQL_DATABASE
fi


if [[ -z $COSMOSDB_SQL_CONTAINER ]]; then
export COSMOSDB_SQL_CONTAINER=sql-container-$RANDOM
az cosmosdb sql container create \
--resource-group $RESOURCE_GROUP \
--account-name $COSMOSDB_ACCOUNT_NAME \
--database-name $COSMOSDB_SQL_DATABASE \
--name $COSMOSDB_SQL_CONTAINER \
--partition-key-path '/id'
fi


export RESULT=$(az cosmosdb sql container show \
--resource-group $RESOURCE_GROUP \
--account-name $COSMOSDB_ACCOUNT_NAME \
--database-name $COSMOSDB_SQL_DATABASE \
--name $COSMOSDB_SQL_CONTAINER \
--output tsv --query id)
az group delete --name $RESOURCE_GROUP --yes || true
if [[ "$RESULT" == "" ]]; then
echo "Failed to create CosmosDB SQL container $COSMOSDB_SQL_CONTAINER"
exit 1
fi