#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Instalasi Nginx"

# Deteksi OS
OS_ID=$(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g')

if [[ "$OS_ID" == "ubuntu" ]]; then
    apt-get update -y
    apt-get install nginx -y
elif [[ "$OS_ID" == "debian" ]]; then
    apt-get update -y
    apt-get install nginx -y
else
    echo -e "[ERROR] OS $OS_ID tidak didukung untuk instalasi nginx"
    exit 1
fi

systemctl enable nginx
systemctl restart nginx

print_success "Nginx berhasil diinstal dan dijalankan"