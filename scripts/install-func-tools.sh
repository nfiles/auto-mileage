#! /bin/bash

URL="https://github.com/Azure/azure-functions-core-tools/releases/download/2.0.3/Azure.Functions.Cli.linux-x64.2.0.3.zip"
DEST="/azure-functions-cli"

wget -q "$URL"

mkdir "$DEST"
unzip -q -d "$DEST" Azure.Functions.Cli.linux-x64.*.zip

chmod +x "$DEST/func"
export PATH=$DEST/func:$PATH
