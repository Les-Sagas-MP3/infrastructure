#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    exit 1
fi

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/conf_instance.sh
VERSION=$1
APP_URL="https://github.com/Les-Sagas-MP3/app/releases/download/${VERSION}/les-sagas-mp3.tar.gz"

# Stop nginx
sudo systemctl stop nginx

# Install app
rm -rf $APP_INSTALL_DIR/*
wget -nv $APP_URL -O $CURRENT_DIR/les-sagas-mp3.tar.gz
tar -xf $CURRENT_DIR/les-sagas-mp3.tar.gz
cp -Rf dist/* $APP_INSTALL_DIR

# Start nginx
sudo systemctl start nginx
