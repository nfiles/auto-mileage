#! /bin/bash

# authenticate with azure
az login \
    --service-principal \
    -u "$CICD_AUTH_NAME" \
    -p "$CICD_AUTH_PASSWORD" \
    --tenant "$CICD_AUTH_TENANT"

# publish the function app
echo "func path: $(which func)"
pushd ./functions
echo "func path: $(which func)"
func azure functionapp publish "$FUNCTIONAPP_NAME" || exit $?
popd

# TODO: publish the client app
