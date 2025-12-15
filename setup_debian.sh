#!/bin/bash

apt update -y
apt upgrade -y

sudo fallocate -l 8G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo "/swapfile   swap    swap    sw  0   0" >>/etc/fstab

mkdir ./backed -p

# change date time
sudo timedatectl set-timezone Asia/Kolkata

sudo apt-get install curl wget iftop iotop screen net-tools inetutils-traceroute htop bash-completion rsync dstat vnstat htop ufw fail2ban sysstat unzip -y
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash



## more ports
# sudo sudo echo "net.ipv4.ip_local_port_range = 9999 65535" >>/etc/sysctl.conf

#good for crawling
# sudo echo "net.ipv4.tcp_fin_timeout = 2" >>/etc/sysctl.conf
# sudo echo "vm.swappiness = 10" >>/etc/sysctl.conf

# also good for crawling but not using it now
# sudo echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf

sudo echo "net.ipv4.ip_local_port_range = 1024 65535" >>/etc/sysctl.conf
sudo echo "net.ipv4.tcp_fin_timeout = 2" >>/etc/sysctl.conf
sudo echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf
sudo echo "vm.swappiness=10" >>/etc/sysctl.conf

sudo echo "net.core.wmem_max = 16777216" >>/etc/sysctl.conf
sudo echo "net.core.wmem_default = 131072" >>/etc/sysctl.conf
sudo echo "net.core.rmem_max = 16777216" >>/etc/sysctl.conf
sudo echo "net.core.rmem_default = 131072" >>/etc/sysctl.conf
sudo echo "net.ipv4.tcp_rmem = 4096 131072 16777216" >>/etc/sysctl.conf
sudo echo "net.ipv4.tcp_wmem = 4096 131072 16777216" >>/etc/sysctl.conf
sudo echo "net.ipv4.tcp_mem = 4096 131072 16777216" >>/etc/sysctl.conf
sudo echo "net.core.netdev_max_backlog = 30000" >>/etc/sysctl.conf
sudo echo "net.core.somaxconn=2147483647" >>/etc/sysctl.conf
sudo echo "vm.overcommit_memory=1" >>/etc/sysctl.conf
sudo echo "fs.file-max = 9223372036854775807" >>/etc/sysctl.conf
sudo echo "vm.max_map_count=9999999" >>/etc/sysctl.conf


sudo echo "session required pam_limits.so" >>/etc/pam.d/common-session
sudo echo "session required pam_limits.so" >>/etc/pam.d/common-session-noninteractive

## file desctiptors
sudo echo "root soft nproc 65535" >>/etc/security/limits.conf
sudo echo "root hard nproc 65535" >>/etc/security/limits.conf
sudo echo "root soft nofile 65535" >>/etc/security/limits.conf
sudo echo "root hard nofile 65535" >>/etc/security/limits.conf

sudo echo "* soft nproc 65535" >>/etc/security/limits.conf
sudo echo "* hard nproc 65535" >>/etc/security/limits.conf
sudo echo "* soft nofile 65535" >>/etc/security/limits.conf
sudo echo "* hard nofile 65535" >>/etc/security/limits.conf

# apply settings
sudo sysctl -p

##check settings
sudo sysctl -a

# will work after re login
ulimit -n


# install docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# add this is /etc/docker/daemon.json
sudo echo > '{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Soft": 1048576,
      "Hard": 1048576
    }
  }
}'> /etc/docker/daemon.json

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

echo "done.  open another terminal and run this command to install node"
echo "nvm install 22"

echo "done. now reboot"
