#! /bin/bash

function guard {
    local status=$1
    if [ $status != 0 ]; then
        echo "failed."
        exit $status
    else
        echo "done."
    fi
    return $status
}

pushd ./function > /dev/null

echo -n "Publishing functionapp... "
func azure functionapp publish --name "$FUNCTIONAPP_NAME"

guard $?

echo "Building client app"
popd > /dev/null
pushd ./clientapp > /dev/null

npm i --no-optional

guard $?

npm run build

guard $?

