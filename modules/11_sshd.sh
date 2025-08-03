#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Konfigurasi SSHD dan Instalasi SSH Custom"

# Download konfigurasi sshd_config custom
wget -O /etc/ssh/sshd_config "${REPO}files/sshd_config"
chmod 600 /etc/ssh/sshd_config

# Download banner
wget -O /etc/issue.net "${REPO}files/banner"
chmod 644 /etc/issue.net

# Set banner pada sshd_config jika belum ada
if ! grep -q "^Banner /etc/issue.net" /etc/ssh/sshd_config; then
  echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi

# Restart SSH service
systemctl restart ssh
systemctl restart sshd

print_success "Konfigurasi SSHD dan Banner selesai"