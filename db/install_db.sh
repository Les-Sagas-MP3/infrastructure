#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    exit 1
fi

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
POSTGRES_INIT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
LSM_DB_INSTALL_DIR=$1
LSM_DB_PASSWORD="lNOYLDKANm0oKOB1kPJk"

# Configure yum repository
cat $CURRENT_DIR/pgdg.repo >> /etc/yum.repos.d/pgdg.repo

# Install yum package
yum makecache
yum install -y postgresql12 postgresql12-server
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable --now postgresql-12

# Allow auth to lessagasmp3 
cat $CURRENT_DIR/pg_hba.conf > /var/lib/pgsql/12/data/pg_hba.conf
systemctl restart postgresql-12

# Set postgres credentials
runuser -l postgres -c "psql -U postgres -c \"ALTER USER POSTGRES WITH PASSWORD '$POSTGRES_INIT_PASSWORD'\""
echo "DB created successfully. Default password for postgres : $POSTGRES_INIT_PASSWORD"

# Create tablespace location
mkdir -p $LSM_DB_INSTALL_DIR
chown postgres:postgres $LSM_DB_INSTALL_DIR

# Create LSM database
runuser -l postgres -c "psql -U postgres -c \"CREATE USER lessagasmp3 WITH PASSWORD '$LSM_DB_PASSWORD'\""
runuser -l postgres -c "psql -U postgres -c \"CREATE TABLESPACE lessagasmp3 OWNER lessagasmp3 LOCATION '$LSM_DB_INSTALL_DIR'\""
runuser -l postgres -c "psql -U postgres -c \"CREATE DATABASE lessagasmp3 WITH OWNER = lessagasmp3 ENCODING = utf8 TABLESPACE = lessagasmp3\""
