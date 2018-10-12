#! /bin/bash

URL="https://github.com/Azure/azure-functions-core-tools/releases/download/2.0.3/Azure.Functions.Cli.linux-x64.2.0.3.zip"
DEST="/azure-functions-cli"

echo "downloading package"
wget -q "$URL"

echo "unpacking package"
mkdir "$DEST"
unzip -q -d "$DEST" Azure.Functions.Cli.linux-x64.*.zip

echo "making binary executable"
chmod +x "$DEST/func"
echo "linking binary to /usr/local/bin"
ln -s "$DEST/func" /usr/local/bin/func
