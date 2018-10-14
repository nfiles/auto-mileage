#! /bin/bash

function sudo {
    $*
}

VERSION_NUMBER="$(lsb_release -rs)"
URL="https://packages.microsoft.com/config/ubuntu/$VERSION_NUMBER/packages-microsoft-prod.deb"
wget -q "$URL"
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install azure-functions-core-tools --no-install-recommends -y
