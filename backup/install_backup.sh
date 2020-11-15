#!/bin/bash

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/../conf_instance.sh
source $CURRENT_DIR/conf.sh

# Install dependencies
yum install git -y

# Create pgpass file
echo "lessagasmp3:5432:lessagasmp3:lessagasmp3:$DB_PASSWORD" > $HOME/.pgpass
chmod 600 $HOME/.pgpass

# Create backup storage
mkdir -p $BACKUPDIR

# Checkout tools
git clone https://github.com/Thomah/postgres-tools.git $BACKUP_INSTALL_DIR
cp $CURRENT_DIR/conf.sh $BACKUP_INSTALL_DIR/conf/production.sh

# Setup cron
cp $CURRENT_DIR/backup.sh /etc/cron.daily/backup_lessagasmp3.sh
