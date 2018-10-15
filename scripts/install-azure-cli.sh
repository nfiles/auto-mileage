#! /bin/bash

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-get update -qq
apt-get install azure-cli --no-install-recommends -y

echo az --version
az --version
