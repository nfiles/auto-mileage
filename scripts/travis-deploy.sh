#! /bin/bash

docker build -t cicd-deploy -f Dockerfile.deploy .
docker run --rm \
    -e TRAVIS \
    -e CICD_AUTH_NAME \
    -e CICD_AUTH_PASSWORD \
    -e CICD_AUTH_TENANT \
    -e FUNCTIONAPP_NAME \
    cicd-deploy
