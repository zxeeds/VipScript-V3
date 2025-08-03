#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi dan Konfigurasi Fail2Ban & Banner"

# Install fail2ban
apt-get update -y
apt-get install -y fail2ban

# Download konfigurasi jail.local
wget -O /etc/fail2ban/jail.local "${REPO}files/jail.local"
chmod 644 /etc/fail2ban/jail.local

# Download banner fail2ban (opsional, jika digunakan pada action)
wget -O /etc/fail2ban/banner.txt "${REPO}files/banner.txt"
chmod 644 /etc/fail2ban/banner.txt

# Restart dan enable fail2ban
systemctl restart fail2ban
systemctl enable fail2ban

print_success "Instalasi dan konfigurasi Fail2Ban selesai"