#!/bin/bash

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/../conf_instance.sh

# Feed target directory
mkdir -p $CORE_INSTALL_DIR
cp -f $CURRENT_DIR/application.properties $CORE_INSTALL_DIR/application.properties
cp -f $CURRENT_DIR/core.sh $CORE_INSTALL_DIR/core.sh
cp -f $CURRENT_DIR/core.service /etc/systemd/system/les-sagas-mp3-core.service
wget -nv $CORE_URL -O $CORE_INSTALL_DIR/core.jar
chmod 775 $CORE_INSTALL_DIR/core.jar
chmod 755 $CORE_INSTALL_DIR/core.sh

# Grant all install directory to user
chown -R lessagasmp3:lessagasmp3 $CORE_INSTALL_DIR

# Run the app
systemctl daemon-reload
systemctl enable les-sagas-mp3-core
systemctl start les-sagas-mp3-core
