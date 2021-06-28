#!/bin/bash

set -eE

JAVA_ARCHIVE_NAME="openjdk-16.0.1_linux-x64_bin.tar.gz"
JAVA_ARCHIVE_URL="https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-x64_bin.tar.gz"
JAVA_CHECKSUM="b1198ffffb7d26a3fdedc0fa599f60a0d12aa60da1714b56c1defbce95d8b235"
JAVA_INSTALL_DIR="/opt/java"

INSTALL_DIR="/opt/les-sagas-mp3"

STORAGE_FOLDER=/mnt/s3/lessagasmp3

DB_INSTALL_DIR="$INSTALL_DIR/db"
DB_PASSWORD="lNOYLDKANm0oKOB1kPJk"

BACKUP_INSTALL_DIR="$INSTALL_DIR/backup"

CORE_INSTALL_DIR="$INSTALL_DIR/core"
CORE_URL="https://github.com/Les-Sagas-MP3/core/releases/download/0.2.12/core-exec.jar"

APP_INSTALL_DIR="$INSTALL_DIR/app"
APP_ADMIN_EMAIL="thomas.hingant@posteo.net"
APP_URL="https://github.com/Les-Sagas-MP3/app/releases/download/0.2.0/les-sagas-mp3.tar.gz"

DEPLOY_INSTALL_DIR="$INSTALL_DIR/deploy"
