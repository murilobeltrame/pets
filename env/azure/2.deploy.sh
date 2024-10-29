#!/bin/bash

# Build and package ExpressJS app
docker build -t webapp .

# Define variables for Azure Container Registry
acrName=""
location=""
resourceGroupName=""

echo "Please enter the resource group name:"
read resourceGroupName

echo "Please enter the container registry name:"
read acrName

echo "Please enter the location:"
read location

# Create Azure Container Registry
az acr create --resource-group $resourceGroupName --name $acrName --sku Standard --location $location

# Log in to Azure Container Registry
docker login $acrName.azurecr.io

# Tag and push Docker image to Azure Container Registry
docker tag webapp $acrName.azurecr.io/webapp:latest
docker push $acrName.azurecr.io/webapp:latest
