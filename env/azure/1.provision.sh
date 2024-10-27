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

webappName="$resourceGroupName-webapp"
appServicePlanName="$resourceGroupName-appserviceplan"

# Create an App Service Plan
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --is-linux

# Create a Web App
runtime="NODE:20-lts"

az webapp create --name $webappName --resource-group $resourceGroupName --plan $appServicePlanName --runtime $runtime

# Create PostgreSQL Database Server
pgservername="$resourceGroupName-pgserver"
postgresVersion="11"
skuName="B_Gen5_1"

az postgres server create --name $pgservername --resource-group $resourceGroupName --location $location --admin-user $pgadminusername --admin-password $pgadminpassword --sku-name $skuName --version $postgresVersion

# Create Database
dbname="Pets"
az postgres db create --name $dbname --resource-group $resourceGroupName --server-name $pgservername

# Update Web App to set environment variable for PostgreSQL connection string
connectionString=$(az postgres server show-credentials --name $pgservername --resource-group $resourceGroupName --query connectionString -o tsv)
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "PG_CONNECTIONSTRING=$connectionString"

# Create an environment variable for JWT secret
jwtSecret=$(openssl rand -base64 32)
az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings "JWT_SECRET=$jwtSecret"
