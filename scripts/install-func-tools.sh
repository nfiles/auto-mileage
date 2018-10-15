#! /bin/bash

VERSION_NUMBER="$(lsb_release -rs)"
wget -q "https://packages.microsoft.com/config/ubuntu/$VERSION_NUMBER/packages-microsoft-prod.deb"
dpkg -i packages-microsoft-prod.deb
apt-get update -qq
apt-get install azure-functions-core-tools --no-install-recommends -y

func --version
