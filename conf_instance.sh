#!/bin/bash

set -eE

JAVA_ARCHIVE_NAME="openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_ARCHIVE_URL="https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_CHECKSUM="83ec3a7b1649a6b31e021cde1e58ab447b07fb8173489f27f427e731c89ed84a"
JAVA_INSTALL_DIR="/opt/java"

INSTALL_DIR="/opt/les-sagas-mp3"

DB_INSTALL_DIR="$INSTALL_DIR/db"
DB_PASSWORD="lNOYLDKANm0oKOB1kPJk"

CORE_INSTALL_DIR="$INSTALL_DIR/core"
CORE_URL="https://github.com/Les-Sagas-MP3/core/releases/download/0.2.12/core-exec.jar"

APP_INSTALL_DIR="$INSTALL_DIR/app"
APP_ADMIN_EMAIL="thomas.hingant@posteo.net"
APP_URL="https://github.com/Les-Sagas-MP3/app/releases/download/0.2.0/les-sagas-mp3.tar.gz"

DEPLOY_INSTALL_DIR="$INSTALL_DIR/deploy"
