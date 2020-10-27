#!/bin/bash

set -eE

JAVA_ARCHIVE_NAME="openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_ARCHIVE_URL="https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_CHECKSUM="83ec3a7b1649a6b31e021cde1e58ab447b07fb8173489f27f427e731c89ed84a"
JAVA_INSTALL_DIR="/opt/java"

INSTALL_DIR="/opt/les-sagas-mp3"
CORE_INSTALL_DIR="$INSTALL_DIR/core"
CORE_URL="https://github.com/Les-Sagas-MP3/core/releases/download/0.2.10/core-exec.jar"

CURRENT_DIR=$(dirname $(realpath $0))
echo "Run configuration in : $CURRENT_DIR"

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

# Create user & group
if ! id lessagasmp3 &>/dev/null; then
useradd lessagasmp3
fi

# Install DB
if (( $(ps -ef | grep -v grep | grep postgresql-12 | wc -l) > 0 )); then

tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg12]
name=PostgreSQL 12 for RHEL/CentOS 7 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF

yum makecache
yum install -y postgresql12 postgresql12-server
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable --now postgresql-12

su postgres <<'EOF'
psql -c "alter user postgres with password 'postgres'"
EOF

fi

# Stop core if running
# TODO

# Install core
mkdir -p $CORE_INSTALL_DIR
cp -f $CURRENT_DIR/core/application.properties $CORE_INSTALL_DIR/application.properties
cp -f $CURRENT_DIR/core/core.sh $CORE_INSTALL_DIR/core.sh
cp -f $CURRENT_DIR/core/core.service /etc/systemd/system/les-sagas-mp3-core.service
wget -nv $CORE_URL -O $CORE_INSTALL_DIR/core.jar
chmod 755 $CORE_INSTALL_DIR/core.jar $CORE_INSTALL_DIR/core.sh

# Grant all install directory to user
chown -R lessagasmp3:lessagasmp3 $INSTALL_DIR