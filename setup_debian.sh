#!/bin/bash

apt update -y
apt upgrade -y

 fallocate -l 8G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo "/swapfile   swap    swap    sw  0   0" >>/etc/fstab

mkdir ./backed -p

# change date time
 timedatectl set-timezone Asia/Kolkata

 apt-get install curl wget iftop iotop screen net-tools inetutils-traceroute htop bash-completion rsync dstat vnstat htop ufw fail2ban sysstat unzip libc++-dev -y
 apt-get install build-essential zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev apt-transport-https ca-certificates curl gnupg-agent  libc++-dev -y

# install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash



## more ports
#   echo "net.ipv4.ip_local_port_range = 9999 65535" >>/etc/sysctl.conf

#good for crawling
#  echo "net.ipv4.tcp_fin_timeout = 2" >>/etc/sysctl.conf
#  echo "vm.swappiness = 10" >>/etc/sysctl.conf

# also good for crawling but not using it now
#  echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf

 echo "net.ipv4.ip_local_port_range = 1024 65535" >>/etc/sysctl.conf
 echo "net.ipv4.tcp_fin_timeout = 2" >>/etc/sysctl.conf
 echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf
 echo "vm.swappiness=10" >>/etc/sysctl.conf

 echo "net.core.wmem_max = 16777216" >>/etc/sysctl.conf
 echo "net.core.wmem_default = 131072" >>/etc/sysctl.conf
 echo "net.core.rmem_max = 16777216" >>/etc/sysctl.conf
 echo "net.core.rmem_default = 131072" >>/etc/sysctl.conf
 echo "net.ipv4.tcp_rmem = 4096 131072 16777216" >>/etc/sysctl.conf
 echo "net.ipv4.tcp_wmem = 4096 131072 16777216" >>/etc/sysctl.conf
 echo "net.ipv4.tcp_mem = 4096 131072 16777216" >>/etc/sysctl.conf
 echo "net.core.netdev_max_backlog = 30000" >>/etc/sysctl.conf
 echo "net.core.somaxconn=2147483647" >>/etc/sysctl.conf
 echo "vm.overcommit_memory=1" >>/etc/sysctl.conf
 echo "fs.file-max = 9223372036854775807" >>/etc/sysctl.conf
 echo "vm.max_map_count=9999999" >>/etc/sysctl.conf


 echo "session required pam_limits.so" >>/etc/pam.d/common-session
 echo "session required pam_limits.so" >>/etc/pam.d/common-session-noninteractive

## file desctiptors
 echo "root soft nproc 1048576" >>/etc/security/limits.conf
 echo "root hard nproc 1048576" >>/etc/security/limits.conf
 echo "root soft nofile 1048576" >>/etc/security/limits.conf
 echo "root hard nofile 1048576" >>/etc/security/limits.conf

 echo "* soft nproc 1048576" >>/etc/security/limits.conf
 echo "* hard nproc 1048576" >>/etc/security/limits.conf
 echo "* soft nofile 1048576" >>/etc/security/limits.conf
 echo "* hard nofile 1048576" >>/etc/security/limits.conf

# apply settings
 sysctl -p

##check settings
 sysctl -a

# will work after re login
ulimit -n


# install docker
 curl -fsSL https://get.docker.com -o get-docker.sh
 sh get-docker.sh
# add this json to set ulimits for docker containers
 mkdir -p /etc/docker
 tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
	"default-ulimits": {
		"nofile": {
			"Name": "nofile",
			"Soft": 1048576,
			"Hard": 1048576
		}
	}
}
EOF

# restart docker to apply the new daemon config (ignore errors if systemctl unavailable)
 systemctl restart docker ||  service docker restart || true

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

echo "done.  open another terminal and run this command to install node"
echo "nvm install 22"

echo "done. now reboot"
