#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Menginstall Paket Dasar yang Dibutuhkan"

# Update dan instal paket-paket dasar
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

apt-get install -y \
    zip pwgen openssl netcat-openbsd socat cron bash-completion figlet ntpdate sudo \
    debconf-utils software-properties-common speedtest-cli vnstat libnss3-dev libnspr4-dev \
    pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev \
    flex bison make libnss3-tools libevent-dev bc rsyslog dos2unix zlib1g-dev libssl-dev \
    libsqlite3-dev sed dirmngr libxml-parser-perl build-essential gcc g++ python3 htop lsof \
    tar wget curl ruby unzip p7zip-full python3-pip libc6 util-linux msmtp-mta ca-certificates \
    bsd-mailx iptables iptables-persistent netfilter-persistent net-tools gnupg gnupg2 \
    lsb-release shc cmake git screen xz-utils apt-transport-https gnupg1 dnsutils jq \
    openvpn easy-rsa

# Bersihkan paket yang tidak perlu
apt-get autoremove -y
apt-get autoclean -y

# Enable dan restart chrony untuk sinkronisasi waktu
systemctl enable chrony
systemctl restart chrony
chronyc sourcestats -v
chronyc tracking -v

# Sinkronisasi waktu dengan ntpdate
ntpdate pool.ntp.org

print_success "Paket Dasar Selesai diinstall"