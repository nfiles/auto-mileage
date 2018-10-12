#! /bin/bash

SECRETS_FILE=".secrets.json"

if [ -f "$SECRETS_FILE" ]; then
    echo "auto-mileage has already been deployed"
    exit 1
fi

# check to see if there is a resource group with the prefix
RESOURCE_GROUP="$(az group list \
    --query "[?starts_with(name,'auto-mileage-')].{name: name}" \
    --output tsv)"

if [ -z "$RESOURCE_GROUP" ]; then
    # group doesn't exist, create new random id
    ID="-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)"
else
    # get the existing ID from the resource group
    # 13 = length of "auto-mileage-"
    ID="${RESOURCE_GROUP:13}"
fi

ID=""

LOCATION="eastus2"
RESOURCE_GROUP="auto-mileage$ID"
APPSERVICE_NAME="service-plan$ID"
STORAGE_ACCONT="automileagestorage$ID"
FUNCTIONAPP_NAME="auto-mileage-func$ID"
CICD_AUTH_NAME="auto-mileage-cicd$ID"
CICD_AUTH_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"

# create the resource group...
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    > /dev/null
status=$?

if [ $status -ne 0 ]; then
    exit $status
fi

RESOURCE_GROUP_ID="$(az group show \
                        --name "$RESOURCE_GROUP" \
                        --query "id" \
                        --output tsv)"

# create the app service plan
az appservice plan create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APPSERVICE_NAME" \
    --is-linux \
    --location "$LOCATION" \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

# create the storage account
az storage account create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$STORAGE_ACCONT" \
    --https-only \
    --kind StorageV2 \
    --sku Standard_LRS \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

# enable static website support on storage container
az extension add --name storage-preview > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

az storage blob service-properties update \
    --account-name "$STORAGE_ACCONT" \
    --static-website \
    --404-document 404.html \
    --index-document index.html \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

STORAGE_CONNECTION="$(az storage account show-connection-string \
                        --name "$STORAGE_ACCONT" \
                        --resource-group "$RESOURCE_GROUP" \
                        --output tsv)"

if [ $status -ne 0 ]; then
    exit $status
fi

# create the functionapp
az functionapp create \
    --plan "$APPSERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$FUNCTIONAPP_NAME" \
    --storage-account "$STORAGE_ACCONT" \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

STORAGE_WEB_URL="$(az storage account show \
                    --resource-group "$RESOURCE_GROUP" \
                    --name "$STORAGE_ACCONT" \
                    --query "primaryEndpoints.web" \
                    --output tsv)"

az functionapp config appsettings set \
    --name "$FUNCTIONAPP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings STORAGE_WEB_URL="$STORAGE_WEB_URL" \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

# create the automation credentials

az ad sp create-for-rbac \
    --name "$CICD_AUTH_NAME" \
    --password "$CICD_AUTH_PASSWORD" \
    --scopes "$RESOURCE_GROUP_ID" \
    > /dev/null

if [ $status -ne 0 ]; then
    exit $status
fi

CICD_AUTH_TENANT="$(az ad sp show \
                        --id "http://$CICD_AUTH_NAME" \
                        --query appOwnerTenantId \
                        --output tsv)"

# output the results
echo "{"                                                    > "$SECRETS_FILE"
echo "  \"RESOURCE_GROUP\": \"$RESOURCE_GROUP\","           >> "$SECRETS_FILE"
echo "  \"STORAGE_CONNECTION\": \"$STORAGE_CONNECTION\","   >> "$SECRETS_FILE"
echo "  \"STORAGE_WEB_URL\": \"$STORAGE_WEB_URL\","         >> "$SECRETS_FILE"
echo "  \"FUNCTIONAPP_NAME\": \"$FUNCTIONAPP_NAME\","       >> "$SECRETS_FILE"
echo "  \"CICD_AUTH_NAME\": \"http://$CICD_AUTH_NAME\","    >> "$SECRETS_FILE"
echo "  \"CICD_AUTH_PASSWORD\": \"$CICD_AUTH_PASSWORD\","   >> "$SECRETS_FILE"
echo "  \"CICD_AUTH_TENANT\": \"$CICD_AUTH_TENANT\""        >> "$SECRETS_FILE"
echo "}"                                                    >> "$SECRETS_FILE"
