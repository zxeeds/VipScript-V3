#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Memasang SSL Certificate untuk Domain Xray"

# Hapus sertifikat lama
rm -rf /etc/xray/xray.key
rm -rf /etc/xray/xray.crt

# Ambil domain dari file /root/domain
domain=$(cat /root/domain)

# Matikan webserver yang menggunakan port 80, jika ada
STOPWEBSERVER=$(lsof -i:80 | awk 'NR==2{print $1}')
if [[ -n "$STOPWEBSERVER" ]]; then
  systemctl stop "$STOPWEBSERVER" || true
fi
systemctl stop nginx || true

# Download dan install acme.sh
rm -rf /root/.acme.sh
mkdir -p /root/.acme.sh
curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh

# Upgrade acme.sh dan set ke Let's Encrypt
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# Issue certificate (ECC 256)
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256

# Install certificate ke Xray
/root/.acme.sh/acme.sh --installcert -d "$domain" \
  --fullchainpath /etc/xray/xray.crt \
  --keypath /etc/xray/xray.key \
  --ecc

chmod 777 /etc/xray/xray.key

print_success "SSL Certificate berhasil dipasang"