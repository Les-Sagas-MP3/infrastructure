#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    exit 1
fi

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/conf_instance.sh
VERSION=$1
CORE_URL="https://github.com/Les-Sagas-MP3/core/releases/download/${VERSION}/core-exec.jar"

# Stop the app
sudo systemctl stop les-sagas-mp3-core

# Feed target directory
wget -nv $CORE_URL -O $CORE_INSTALL_DIR/core.jar

# Run the app
sudo systemctl start les-sagas-mp3-core
