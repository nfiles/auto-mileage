#! /bin/bash

# authenticate with azure
az login \
    --service-principal \
    -u "$CICD_AUTH_NAME" \
    -p "$CICD_AUTH_PASSWORD" \
    --tenant "$CICD_AUTH_TENANT" \
    | /dev/null > \
    || exit $?

az account show

# publish the function app
pushd ./functions
func azure functionapp publish "$FUNCTIONAPP_NAME" || exit $?
popd

# TODO: publish the client app
