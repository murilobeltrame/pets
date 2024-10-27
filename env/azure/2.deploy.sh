#!/bin/bash

# Define variables for Azure Web App and ExpressJS app
webAppName=""
resourceGroupName=""

echo "Please enter the web app name:"
read webAppName

echo "Please enter the resource group name:"
read resourceGroupName

# Build and package ExpressJS app
npm install
npm run build
zip -r expressjs-app.zip ./dist

# Deploy ExpressJS app to Azure Web App
az webapp deployment source config-zip --name $webAppName \
    --resource-group $resourceGroupName \
    --src-path ./expressjs-app.zip

echo "Deployment completed successfully!"
