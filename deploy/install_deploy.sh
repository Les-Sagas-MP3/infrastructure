#!/bin/bash

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/../conf_instance.sh

# Create deploy location and copy scripts
mkdir -p $DEPLOY_INSTALL_DIR
cp $CURRENT_DIR/core.sh $DEPLOY_INSTALL_DIR
cp $CURRENT_DIR/app.sh $DEPLOY_INSTALL_DIR
cp $CURRENT_DIR/../conf_instance.sh $DEPLOY_INSTALL_DIR/conf_instance.sh
chown -R lessagasmp3:lessagasmp3 $DEPLOY_INSTALL_DIR
chmod 774 $DEPLOY_INSTALL_DIR
chmod 755 $DEPLOY_INSTALL_DIR/*.sh
