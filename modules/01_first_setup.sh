#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Setup Timezone, iptables-persistent, dan HAProxy"

# Set timezone to Asia/Jakarta
timedatectl set-timezone Asia/Jakarta

# Preseed iptables-persistent supaya tidak prompt
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

# Instal iptables-persistent
apt-get update -y
apt-get install -y iptables-persistent netfilter-persistent

# Deteksi OS dan install HAProxy sesuai OS
OS_ID=$(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g')
if [[ "$OS_ID" == "ubuntu" ]]; then
    print_install "Setup Dependencies untuk Ubuntu"
    apt-get install -y haproxy
elif [[ "$OS_ID" == "debian" ]]; then
    print_install "Setup Dependencies untuk Debian"
    curl https://haproxy.debian.net/bernat.debian.org.gpg | gpg --dearmor >/usr/share/keyrings/haproxy.debian.net.gpg
    echo deb "[signed-by=/usr/share/keyrings/haproxy.debian.net.gpg]" \
      http://haproxy.debian.net buster-backports-1.8 main \
      >/etc/apt/sources.list.d/haproxy.list
    apt-get update
    apt-get -y install haproxy=1.8.*
else
    echo -e "[ERROR] OS $OS_ID tidak didukung untuk instalasi HAProxy"
    exit 1
fi

print_success "Timezone, iptables-persistent, dan HAProxy berhasil disetup"