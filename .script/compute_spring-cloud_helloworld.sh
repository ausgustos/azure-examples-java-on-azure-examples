#!/bin/bash
cd ..


if [[ -z $RESOURCE_GROUP ]]; then
export RESOURCE_GROUP=java-on-azure-$RANDOM
export REGION=southcentralus
fi

az group create --name $RESOURCE_GROUP --location $REGION
az extension add --name spring-cloud

export SPRING_CLOUD_NAME=springcloud-$RANDOM

az spring-cloud create \
--resource-group $RESOURCE_GROUP \
--name $SPRING_CLOUD_NAME

cd compute/spring-cloud/helloworld

mvn package
az spring app create \
--name helloworld \
--service ${SPRING_CLOUD_NAME} \
--resource-group ${RESOURCE_GROUP} \
--is-public true

az spring app deploy \
--name helloworld \
--service ${SPRING_CLOUD_NAME} \
--resource-group ${RESOURCE_GROUP} \
--artifact-path ./target/springcloud-helloworld.jar

az spring app show \
--name helloworld \
--service ${SPRING_CLOUD_NAME} \
--resource-group ${RESOURCE_GROUP} \
--query properties.url \
--output tsv

export URL=$(az spring app show \
--name helloworld \
--service ${SPRING_CLOUD_NAME} \
--resource-group ${RESOURCE_GROUP} \
--query properties.url \
--output tsv)
export RESULT=$(curl $URL)

az group delete --name $RESOURCE_GROUP --yes || true

if [[ "$RESULT" != *"Hello World"* ]]; then
echo "Response did not contain 'Hello World'"
exit 1
fi