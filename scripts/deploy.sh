#! /bin/bash

# publish the function app
echo "func path: $(which func)"
pushd ./functions
echo "func path: $(which func)"
func azure functionapp publish "$FUNCTIONAPP_NAME" || exit $?
popd

# TODO: publish the client app
