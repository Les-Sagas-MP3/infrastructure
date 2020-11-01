#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    exit 1
fi

# Init configuration
ADMIN_EMAIL="thomas.hingant@posteo.net"
CURRENT_DIR=$(dirname $(realpath $0))

# Install nginx
amazon-linux-extras install epel
amazon-linux-extras install nginx1

# Copy servers conf
cp $CURRENT_DIR/api.conf /etc/nginx/conf.d/api.conf

# Start nginx
systemctl start nginx
systemctl enable nginx

# Install Let's Encrypt Certbot
yum install -y certbot python-certbot-nginx
#certbot --nginx -d api.les-sagas-mp3.fr -m $ADMIN_EMAIL --agree-tos -n
#certbot renew --dry-run
