#! /bin/bash

# authenticate with azure
echo az login
echo     --service-principal
echo     -u "$CICD_AUTH_NAME"
echo     -p "$CICD_AUTH_PASSWORD"
echo     --tenant "$CICD_AUTH_TENANT"
az login \
    --service-principal \
    -u "$CICD_AUTH_NAME" \
    -p "$CICD_AUTH_PASSWORD" \
    --tenant "$CICD_AUTH_TENANT" \
    || exit $?

# publish the function app
pushd ./functions
func azure functionapp publish "$FUNCTIONAPP_NAME" || exit $?
popd

# TODO: publish the client app
