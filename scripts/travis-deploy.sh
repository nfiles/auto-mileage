#! /bin/bash

docker build -t cicd-deploy -f Dockerfile.deploy .
docker run cicd-deploy \
    --rm \
    -e TRAVIS \
    -e CICD_AUTH_NAME \
    -e CICD_AUTH_PASSWORD \
    -e CICD_AUTH_TENANT \
    -e FUNCTIONAPP_NAME
