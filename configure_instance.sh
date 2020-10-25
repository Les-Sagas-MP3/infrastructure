#!/bin/bash

set -eE

JAVA_ARCHIVE_NAME="openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_ARCHIVE_URL="https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_CHECKSUM="83ec3a7b1649a6b31e021cde1e58ab447b07fb8173489f27f427e731c89ed84a"
JAVA_INSTALL_DIR="/opt/java"

# Backup original environment file
if [ ! -f /etc/environment.bak ]
then
    cp /etc/environment /etc/environment.bak
fi
cp -f /etc/environment.bak /etc/environment

# Update OS packages
yum update -y

# Retrieve Java package
wget -nv $JAVA_ARCHIVE_URL -O $JAVA_ARCHIVE_NAME
echo "$JAVA_CHECKSUM $JAVA_ARCHIVE_NAME" | sha256sum --check
mkdir -p $JAVA_INSTALL_DIR
tar -xf $JAVA_ARCHIVE_NAME -C $JAVA_INSTALL_DIR

# Set environment variables
JAVA_HOME="$JAVA_INSTALL_DIR/$(ls -t $JAVA_INSTALL_DIR | head -n1)"
PATH=$PATH:$JAVA_HOME/bin
echo "JAVA_HOME: $JAVA_HOME"
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment
echo "export PATH=$PATH" >> /etc/environment

