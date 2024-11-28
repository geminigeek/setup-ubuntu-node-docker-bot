#!/bin/bash

echo "deb [arch=amd64] http://nginx.org/packages/mainline/debian/ bookworm nginx" >>/etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/mainline/debian/ bookworm nginx" >>/etc/apt/sources.list.d/nginx.list

apt update -y

curl -O https://nginx.org/keys/nginx_signing.key && apt-key add ./nginx_signing.key
apt-key export 7BD9BF62 | gpg --dearmour -o /etc/apt/trusted.gpg.d/nginx-key.gpg

apt update -y

apt install nginx -y

sudo systemctl start nginx
sudo systemctl enable nginx
