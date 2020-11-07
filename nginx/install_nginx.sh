#!/bin/bash

# Init configuration
CURRENT_DIR=$(dirname $(realpath $0))
source $CURRENT_DIR/../conf_instance.sh

# Install nginx
amazon-linux-extras install epel
amazon-linux-extras install nginx1

# Copy servers conf
cp $CURRENT_DIR/*.conf /etc/nginx/conf.d/

# Start nginx
systemctl start nginx
systemctl enable nginx

# Install Let's Encrypt Certbot
yum install -y certbot python-certbot-nginx
certbot --nginx -d api.les-sagas-mp3.fr -m $APP_ADMIN_EMAIL --agree-tos -n
certbot --nginx -d app.les-sagas-mp3.fr -m $APP_ADMIN_EMAIL --agree-tos -n
certbot --nginx -d www.les-sagas-mp3.fr -m $APP_ADMIN_EMAIL --agree-tos -n

# Configure automatic renewal
echo "39 1,13 * * * root certbot renew --no-self-upgrade" >> /etc/crontab
systemctl restart crond

# Install app
mkdir -p $APP_INSTALL_DIR
wget -nv $APP_URL -O $CURRENT_DIR/les-sagas-mp3.tar.gz
tar -xf $CURRENT_DIR/les-sagas-mp3.tar.gz
cp -Rf dist/* $APP_INSTALL_DIR
