#!/bin/bash

set -eE

CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/conf_instance.sh

# Backup original environment file
if [ ! -f /etc/environment.bak ]
then
    cp /etc/environment /etc/environment.bak
fi
cp -f /etc/environment.bak /etc/environment

# Update OS packages
yum update -y

# Create app user & group
if ! id lessagasmp3 &>/dev/null; then
    useradd lessagasmp3
fi

# Create github user & group
if ! id github &>/dev/null; then
    useradd -m github
    usermod -aG lessagasmp3 github
    #echo "github  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/github
    echo "%github ALL= NOPASSWD: /bin/systemctl stop les-sagas-mp3-core" | sudo tee /etc/sudoers.d/github
    echo "%github ALL= NOPASSWD: /bin/systemctl start les-sagas-mp3-core" >> /etc/sudoers.d/github
    echo "%github ALL= NOPASSWD: /bin/systemctl stop nginx" >> /etc/sudoers.d/github
    echo "%github ALL= NOPASSWD: /bin/systemctl start nginx" >> /etc/sudoers.d/github
    GITHUB_HOME=/home/github
    mkdir -p $GITHUB_HOME/.ssh
    mv $CURRENT_DIR/github.pub $GITHUB_HOME/.ssh/authorized_keys
    chown github:github -R $GITHUB_HOME/.ssh
    chmod 700 -R $GITHUB_HOME/.ssh
    chmod 600 $GITHUB_HOME/.ssh/authorized_keys
fi

# Install DB
if (( $(ps -ef | grep -v grep | grep pgsql-12 | wc -l) <= 0 )); then
    $CURRENT_DIR/db/install_db.sh
fi

# Retrieve Java package
wget -nv $JAVA_ARCHIVE_URL -O $JAVA_ARCHIVE_NAME
echo "$JAVA_CHECKSUM $JAVA_ARCHIVE_NAME" | sha256sum --check
mkdir -p $JAVA_INSTALL_DIR
tar -xf $JAVA_ARCHIVE_NAME -C $JAVA_INSTALL_DIR

# Set environment variables
JAVA_HOME="$JAVA_INSTALL_DIR/$(ls -t $JAVA_INSTALL_DIR | head -n1)"
PATH=$PATH:$JAVA_HOME/bin
echo "JAVA_HOME: $JAVA_HOME"
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/bashrc
echo "export PATH=$PATH" >> /etc/bashrc

# Install core
if (( $(ps -ef | grep -v grep | grep core.jar | wc -l) <= 0 )); then
    $CURRENT_DIR/core/install_core.sh
fi

# Install nginx & app
if (( $(ps -ef | grep -v grep | grep nginx | wc -l) <= 0 )); then
    $CURRENT_DIR/nginx/install_nginx.sh
fi

# Install deploy scripts
$CURRENT_DIR/deploy/install_deploy.sh
