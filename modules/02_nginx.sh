#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
source config/variables.sh
source lib/utils.sh

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

curl "${REPO}cfg/nginx.conf" > /etc/nginx/nginx.conf

# Tambahkan konfigurasi untuk .well-known/acme-challenge
NGINX_CONF="/etc/nginx/sites-enabled/default"

if [[ -f "$NGINX_CONF" ]]; then
    echo "Menambahkan konfigurasi .well-known/acme-challenge ke Nginx"
    cat <<EOL > "$NGINX_CONF"
server {
    listen 80;
    server_name _;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 404;
    }
}
EOL
else
    echo -e "[ERROR] File konfigurasi Nginx tidak ditemukan: $NGINX_CONF"
    exit 1
fi

# Buat direktori untuk .well-known/acme-challenge jika belum ada
mkdir -p /var/www/html/.well-known/acme-challenge

# Set izin direktori
chmod -R 755 /var/www/html/.well-known

# Restart Nginx
systemctl enable nginx
systemctl restart nginx

print_success "Nginx berhasil diinstal dan dikonfigurasi untuk .well-known/acme-challenge"