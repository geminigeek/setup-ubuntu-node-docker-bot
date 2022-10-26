#!/bin/bash



fallocate -l 8G /swapfile &&  chmod 600 /swapfile &&  mkswap /swapfile && swapon /swapfile
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
timedatectl set-timezone  Asia/Kolkata


apt update -y

# install dev tools


apt-get install curl wget iftop iotop screen net-tools inetutils-traceroute -y
apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev  apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common -y

# install node
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
node -v

npm i pm2 nodemon -g

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh


## more ports
echo  "net.ipv4.ip_local_port_range = 1024 65535" >> /etc/sysctl.conf

#good for crawling
echo "net.ipv4.tcp_fin_timeout = 2" >> /etc/sysctl.conf
# also good for crawling but not using it now
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session




## file desctiptors
echo "root soft nproc 65535" >> /etc/security/limits.conf
echo "root hard nproc 65535" >> /etc/security/limits.conf
echo "root soft nofile 65535" >> /etc/security/limits.conf
echo "root hard nofile 65535" >> /etc/security/limits.conf


# apply settings
sysctl -p

##check settings
sysctl -a

# will work after re login
ulimit -n

cp /etc/rc.local ./backed/rc.local

cp ./rc.local /etc/rc.local -f
chmod +x /etc/rc.local


# backing if exists
cp /etc/systemd/system/rc-local.service ./backed/system/rc-local.service

cp ./rc-local.service /etc/systemd/system/rc-local.service -f


systemctl enable rc-local
systemctl daemon-reload

systemctl start rc-local.service
systemctl restart rc-local.service
systemctl status rc-local.service

ifconfig

## now download the multitor

git clone https://github.com/geminigeek/docker-multitor.git geminigeek-docker-multitor
cd geminigeek-docker-multitor
docker build -t multitor-orig-polipo-exposed-ha .


# run docker like this
# docker run -d --name multitor10 --restart unless-stopped -e "TOR_INSTANCES=10" -p 15379-15479:15379-15479 -p 16379:16379  -p 16380:16380 multitor-orig-polipo-exposed-ha
docker run -d --name multitor10 --restart unless-stopped -e "TOR_INSTANCES=10" -p 127.0.0.1:15379-15479:15379-15479 -p 127.0.0.1:16379:16379  multitor-orig-polipo-exposed-ha

docker images

echo "now sleeping for 20 sec waiting for tor to start..."
sleep 20

echo "now running curl "
curl -k --location --proxy 127.0.0.1:15379 https://ipinfo.io/ip

## coming back to root
cd ..

npm init -y
npm i got hpagent fingerprint-generator
node test.mjs

mkdir /root/ops-folder -p

cd /root/ops-folder

# now rsync into the /root/ops-folder whatever we want

echo "done.  Now reboot"