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
    ID="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)"
else
    # get the existing ID from the resource group
    # 13 = length of "auto-mileage-"
    ID="${RESOURCE_GROUP:13}"
fi

LOCATION="eastus2"
RESOURCE_GROUP="auto-mileage-$ID"
STORAGE_ACCOUNT="automileagestorage$ID"
FUNCTIONAPP_NAME="auto-mileage-func-$ID"
CICD_AUTH_NAME="auto-mileage-cicd-$ID"
CICD_AUTH_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"

# create the resource group...
echo "creating resource group $RESOURCE_GROUP"...
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    > /dev/null \
    || exit $?

RESOURCE_GROUP_ID="$(az group show \
                        --name "$RESOURCE_GROUP" \
                        --query "id" \
                        --output tsv)"

echo "creating storage account $STORAGE_ACCOUNT"
# create the storage account
az storage account create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$STORAGE_ACCOUNT" \
    --https-only \
    --kind StorageV2 \
    --sku Standard_LRS \
    > /dev/null \
    || exit $?

# enable static website support on storage container
az extension add --name storage-preview > /dev/null \
    || exit $?

echo "configuring static website container"
az storage blob service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --static-website \
    --404-document 404.html \
    --index-document index.html \
    > /dev/null \
    || exit $?

STORAGE_CONNECTION="$(az storage account show-connection-string \
                        --name "$STORAGE_ACCOUNT" \
                        --resource-group "$RESOURCE_GROUP" \
                        --output tsv)"

STORAGE_WEB_URL="$(az storage account show \
                    --resource-group "$RESOURCE_GROUP" \
                    --name "$STORAGE_ACCOUNT" \
                    --query "primaryEndpoints.web" \
                    --output tsv)"

# create the functionapp
echo "creating function app $FUNCTIONAPP_NAME"
az functionapp create \
    --consumption-plan-location "$LOCATION" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$FUNCTIONAPP_NAME" \
    --storage-account "$STORAGE_ACCOUNT" \
    > /dev/null \
    || exit $?

az functionapp config appsettings set \
    --name "$FUNCTIONAPP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings STORAGE_WEB_URL="$STORAGE_WEB_URL" \
    > /dev/null \
    || exit $?

# create the automation credentials
echo "creating automation service principal $CICD_AUTH_NAME"
az ad sp create-for-rbac \
    --name "$CICD_AUTH_NAME" \
    --password "$CICD_AUTH_PASSWORD" \
    --scopes "$RESOURCE_GROUP_ID" \
    > /dev/null \
    || exit $?

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
