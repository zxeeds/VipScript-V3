#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi dan Konfigurasi Dropbear"

# Install Dropbear
apt-get update -y
apt-get install -y dropbear

# Download konfigurasi dropbear custom
wget -O /etc/default/dropbear "${REPO}files/dropbear"
chmod 644 /etc/default/dropbear

# Download banner dropbear
wget -O /etc/dropbear/banner "${REPO}files/banner"
chmod 644 /etc/dropbear/banner

# Aktifkan banner di konfigurasi dropbear jika belum ada
if ! grep -q "^DROPBEAR_BANNER=" /etc/default/dropbear; then
  echo 'DROPBEAR_BANNER="/etc/dropbear/banner"' >> /etc/default/dropbear
fi

# Pastikan dropbear aktif di port 443, 109, 143 (atau sesuai konfigurasi file remote)
systemctl enable dropbear
systemctl restart dropbear

print_success "Dropbear berhasil diinstal dan dikonfigurasi"