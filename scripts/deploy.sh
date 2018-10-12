#! /bin/bash

# publish the function app
pushd ./function
func azure functionapp publish "$FUNCTIONAPP_NAME" || exit $?
popd

# TODO: publish the client app
