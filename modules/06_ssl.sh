#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Memasang SSL Certificate untuk Domain Xray"

# Validasi file domain
if [[ ! -f /root/domain ]]; then
    echo "File /root/domain tidak ditemukan. Skrip dihentikan."
    exit 1
fi

# Ambil domain dari file /root/domain
domain=$(cat /root/domain)
if [[ -z "$domain" ]]; then
    echo "Domain tidak valid atau kosong. Skrip dihentikan."
    exit 1
fi

# Hapus sertifikat lama
rm -rf /etc/xray/xray.key
rm -rf /etc/xray/xray.crt

# Matikan webserver yang menggunakan port 80, jika ada
STOPWEBSERVER=$(lsof -i:80 | awk 'NR==2{print $1}')
if [[ -n "$STOPWEBSERVER" ]]; then
    echo "Menghentikan layanan webserver: $STOPWEBSERVER"
    systemctl stop "$STOPWEBSERVER" || true
fi
echo "Menghentikan layanan nginx jika berjalan"
systemctl stop nginx || true

# Download dan install acme.sh dari sumber resmi
rm -rf /root/.acme.sh
mkdir -p /root/.acme.sh
curl -s https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh

# Upgrade acme.sh dan set ke Let's Encrypt
echo "Mengupgrade acme.sh dan mengatur CA ke Let's Encrypt"
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# Issue certificate (ECC 256)
echo "Mengeluarkan sertifikat untuk domain: $domain"
if ! /root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256; then
    echo "Gagal mengeluarkan sertifikat. Skrip dihentikan."
    exit 1
fi

# Install certificate ke Xray
echo "Memasang sertifikat untuk domain: $domain"
/root/.acme.sh/acme.sh --installcert -d "$domain" \
  --fullchainpath /etc/xray/xray.crt \
  --keypath /etc/xray/xray.key \
  --ecc

# Set permission yang lebih aman untuk kunci privat
chmod 600 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt

print_success "SSL Certificate berhasil dipasang untuk domain: $domain"