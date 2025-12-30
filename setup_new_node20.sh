#!/bin/bash



sudo fallocate -l 8G /swapfile &&  chmod 600 /swapfile &&  mkswap /swapfile && swapon /swapfile
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab

mkdir ./backed -p

# DEBIAN_FRONTEND=noninteractive \
# apt-get \
# -o Dpkg::Options::=--force-confold \
# -o Dpkg::Options::=--force-confdef \
# -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
# update

# # ubuntu update initial
# #apt update -y && apt upgrade -y
# DEBIAN_FRONTEND=noninteractive \
# apt-get \
# -o Dpkg::Options::=--force-confold \
# -o Dpkg::Options::=--force-confdef \
# -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
# dist-upgrade

#working
#https://unix.stackexchange.com/questions/107194/make-apt-get-update-and-upgrade-automate-and-unattended
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo -E apt-get -qy update
sudo -E apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
sudo -E apt-get -qy autoclean

# export DEBIAN_FRONTEND=noninteractive
# export DEBIAN_PRIORITY=critical
# sudo -E apt-get -qy update
# sudo -E apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
# sudo -E apt-get -qy autoclean


# change date time
sudo timedatectl set-timezone  Asia/Kolkata


sudo apt update -y

# install dev tools


sudo apt-get install curl wget iftop iotop screen net-tools inetutils-traceroute htop bash-completion libc++-dev -y
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev  apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common libc++-dev -y

# install node
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt-get update -y
sudo apt-get install -y nodejs
node -v

npm i pm2 nodemon -g

# install docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh


## more ports
sudo sudo echo  "net.ipv4.ip_local_port_range = 1024 65535" >> /etc/sysctl.conf

#good for crawling
sudo echo "net.ipv4.tcp_fin_timeout = 2" >> /etc/sysctl.conf
# also good for crawling but not using it now
sudo echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
sudo echo "session required pam_limits.so" >> /etc/pam.d/common-session




## file desctiptors
sudo echo "root soft nproc 65535" >> /etc/security/limits.conf
sudo echo "root hard nproc 65535" >> /etc/security/limits.conf
sudo echo "root soft nofile 65535" >> /etc/security/limits.conf
sudo echo "root hard nofile 65535" >> /etc/security/limits.conf


# apply settings
sudo sysctl -p

##check settings
sudo sysctl -a

# will work after re login
ulimit -n

sudo cp /etc/rc.local ./backed/rc.local

sudo cp ./rc.local /etc/rc.local -f
sudo chmod +x /etc/rc.local


# backing if exists
sudo cp /etc/systemd/system/rc-local.service ./backed/system/rc-local.service

sudo cp ./rc-local.service /etc/systemd/system/rc-local.service -f


sudo systemctl enable rc-local
sudo systemctl daemon-reload

sudo systemctl start rc-local.service
sudo systemctl restart rc-local.service
sudo systemctl status rc-local.service

sudo ifconfig

## now download the multitor

git clone https://github.com/geminigeek/docker-multitor.git geminigeek-docker-multitor
cd geminigeek-docker-multitor
sudo docker build -t multitor-orig-polipo-exposed-ha .


# run docker like this
# docker run -d --name multitor10 --restart unless-stopped -e "TOR_INSTANCES=10" -p 15379-15479:15379-15479 -p 16379:16379  -p 16380:16380 multitor-orig-polipo-exposed-ha
sudo docker run -d --name multitor10 --restart unless-stopped -e "TOR_INSTANCES=10" -p 127.0.0.1:15379-15479:15379-15479 -p 127.0.0.1:16379:16379  multitor-orig-polipo-exposed-ha

sudo docker images

sudo echo "now sleeping for 20 sec waiting for tor to start..."
sudo sleep 20

sudo echo "now running curl "
sudo curl -k --location --proxy 127.0.0.1:15379 https://ipinfo.io/ip

## coming back to root
cd ..

sudo npm init -y
sudo npm i got hpagent fingerprint-generator
sudo node test.mjs

sudo mkdir /root/ops-folder -p

cd /root/ops-folder

# now rsync into the /root/ops-folder whatever we want

echo "done.  Now reboot"