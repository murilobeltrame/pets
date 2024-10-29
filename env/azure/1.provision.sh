resourceGroupName=""
location=""
pgadminusername=""
pgadminpassword=""

echo "Please enter the name of the resource group:"
read resourceGroupName

echo "Please enter the location for the resource group (e.g. eastus):"
read location

echo "Please enter the admin username for the PostgreSQL server:"
read pgadminusername

echo "Please enter the password for the PostgreSQL server:"
read -s pgadminpassword

az group create --name $resourceGroupName --location $location

# Create an Azure Container Registry
acrName=$(echo "$resourceGroupName-acr" | sed 's/[^a-zA-Z0-9]//g')
acrSkU="Basic"
az acr create --resource-group $resourceGroupName --name $acrName --admin-enabled true --sku $acrSkU

# Create an App Service Plan
appServicePlanName="$resourceGroupName-appserviceplan"
servicePlanSku="F1"
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --is-linux --sku $servicePlanSku

# Create a Web App that hosts containers from the Azure Container Registry
webappName="$resourceGroupName-webapp"
az webapp create --name $webappName \
  --resource-group $resourceGroupName \
  --plan $appServicePlanName \
  --container-registry-url $(az acr show --name $acrName --resource-group $resourceGroupName --query "loginServer" -o tsv) \
  --container-image-name $acrName/webapp:latest \
  --container-registry-user $(az acr credential show --name $acrName --resource-group $resourceGroupName --query "username" -o tsv) \
  --container-registry-password $(az acr credential show --name $acrName --resource-group $resourceGroupName --query "passwords[0].value" -o tsv)

# Create PostgreSQL Database Server
pgservername="$resourceGroupName-pgserver"
postgresVersion="11"
tier="Burstable"
skuName="Standard_B1ms"

az postgres flexible-server create \
    --name $pgservername \
    --resource-group $resourceGroupName \
    --location $location \
    --admin-user $pgadminusername \
    --admin-password $pgadminpassword \
    --version $postgresVersion \
    --tier $tier \
    --sku-name $skuName

# Create Database
dbname="Pets"
az postgres flexible-server db create --database-name $dbname --resource-group $resourceGroupName --server-name $pgservername

# Update Web App to set environment variable for PostgreSQL connection string
dbHostName=$(az postgres flexible-server show -n $pgservername -g $resourceGroupName --query fullyQualifiedDomainName -o tsv)
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "DB_NAME=$dbname"
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "DB_USER=$pgadminusername"
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "DB_PASSWORD=$pgadminpassword"
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "DB_PORT=5432"
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "DB_HOST=$dbHostName"

# Create an environment variable for JWT secret
jwtSecret=$(openssl rand -base64 32)
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "JWT_SECRET=$jwtSecret"

# Set application port 
$port="443"
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "NODE_PORT=$port"
