#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    exit 1
fi

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
LSM_CORE_INSTALL_DIR=$1
LSM_CORE_URL="https://github.com/Les-Sagas-MP3/core/releases/download/0.2.10/core-exec.jar"

# Feed target directory
mkdir -p $LSM_CORE_INSTALL_DIR
cp -f $CURRENT_DIR/application.properties $LSM_CORE_INSTALL_DIR/application.properties
cp -f $CURRENT_DIR/core.sh $LSM_CORE_INSTALL_DIR/core.sh
cp -f $CURRENT_DIR/core.service /etc/systemd/system/les-sagas-mp3-core.service
wget -nv $LSM_CORE_URL -O $LSM_CORE_INSTALL_DIR/core.jar
chmod 755 $LSM_CORE_INSTALL_DIR/core.jar $LSM_CORE_INSTALL_DIR/core.sh

# Grant all install directory to user
chown -R lessagasmp3:lessagasmp3 $LSM_CORE_INSTALL_DIR

# Run the app
systemctl daemon-reload
systemctl enable les-sagas-mp3-core
systemctl start les-sagas-mp3-core
