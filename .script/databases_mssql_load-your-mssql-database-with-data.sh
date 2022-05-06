#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=westus2
fi

az group create --name $RESOURCE_GROUP --location $REGION
export MSSQL_NAME=mssql-$RANDOM
export MSSQL_USERNAME=mssql
export MSSQL_PASSWORD=p#ssw0rd-$RANDOM
if [[ -z $MSSQL_NAME ]]; then
export MSSQL_NAME=mssql-$RANDOM
export MSSQL_USERNAME=mssql
export MSSQL_PASSWORD=p#ssw0rd-$RANDOM
fi
az sql server create \
--admin-user $MSSQL_USERNAME \
--admin-password $MSSQL_PASSWORD \
--name $MSSQL_NAME \
--resource-group $RESOURCE_GROUP
export LOCAL_IP=`curl -s whatismyip.akamai.com`

az sql server firewall-rule create \
--resource-group $RESOURCE_GROUP \
--server $MSSQL_NAME \
--name AllowMyLocalIP \
--start-ip-address $LOCAL_IP \
--end-ip-address $LOCAL_IP

cd databases/mssql/load-your-mssql-database-with-data

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
python -m pip install --upgrade pip
sudo pip install mssql-cli

export MSSQL_DNS_NAME=`az sql server show \
--resource-group $RESOURCE_GROUP \
--name $MSSQL_NAME \
--query fullyQualifiedDomainName \
--output tsv`

export MSSQL_CLIENT_USERNAME="$MSSQL_USERNAME@$MSSQL_NAME"

mssql-cli -S $MSSQL_DNS_NAME -U $MSSQL_CLIENT_USERNAME -P $MSSQL_PASSWORD -i create.sql

mssql-cli -S $MSSQL_DNS_NAME -U $MSSQL_CLIENT_USERNAME -P $MSSQL_PASSWORD -d demo -i load.sql

cd ../../..


az group delete --name $RESOURCE_GROUP --yes || true