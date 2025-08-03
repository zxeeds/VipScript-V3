#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Membuat direktori dan file database untuk Xray dan layanan terkait"

# Hapus database lama jika ada
rm -rf /etc/vmess/.vmess.db
rm -rf /etc/vless/.vless.db
rm -rf /etc/trojan/.trojan.db
rm -rf /etc/shadowsocks/.shadowsocks.db
rm -rf /etc/ssh/.ssh.db
rm -rf /etc/bot/.bot.db

# Buat direktori utama
mkdir -p /etc/bot
mkdir -p /etc/xray
mkdir -p /etc/vmess
mkdir -p /etc/vless
mkdir -p /etc/trojan
mkdir -p /etc/shadowsocks
mkdir -p /etc/ssh
mkdir -p /usr/bin/xray/
mkdir -p /var/log/xray/
mkdir -p /var/www/html

# Buat folder IP untuk masing-masing layanan
mkdir -p /etc/kyt/files/vmess/ip
mkdir -p /etc/kyt/files/vless/ip
mkdir -p /etc/kyt/files/trojan/ip
mkdir -p /etc/kyt/files/ssh/ip

# Buat folder files untuk masing-masing layanan
mkdir -p /etc/files/vmess
mkdir -p /etc/files/vless
mkdir -p /etc/files/trojan
mkdir -p /etc/files/ssh

# Set permission log
chmod +x /var/log/xray

# Buat file domain dan log jika belum ada
touch /etc/xray/domain
touch /var/log/xray/access.log
touch /var/log/xray/error.log

# Buat file database untuk masing-masing layanan
touch /etc/vmess/.vmess.db
touch /etc/vless/.vless.db
touch /etc/trojan/.trojan.db
touch /etc/shadowsocks/.shadowsocks.db
touch /etc/ssh/.ssh.db
touch /etc/bot/.bot.db

# Isi header database
echo "& plughin Account" >> /etc/vmess/.vmess.db
echo "& plughin Account" >> /etc/vless/.vless.db
echo "& plughin Account" >> /etc/trojan/.trojan.db
echo "& plughin Account" >> /etc/shadowsocks/.shadowsocks.db
echo "& plughin Account" >> /etc/ssh/.ssh.db

print_success "Direktori dan file database Xray selesai dibuat"