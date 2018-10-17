#! /bin/bash

SECRETS_FILE=".secrets.json"

if [ ! -f "$SECRETS_FILE" ]; then
    echo "secrets file not found" 1>&2
    exit 1
fi

RESOURCE_GROUP="$(cat "$SECRETS_FILE" | jq .RESOURCE_GROUP)"
CICD_AUTH_NAME="$(cat "$SECRETS_FILE" | jq .CICD_AUTH_NAME)"

az group delete --name "$RESOURCE_GROUP" -y
az ad sp delete --id "$CICD_AUTH_NAME"
