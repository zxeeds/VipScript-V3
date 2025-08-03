#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi Menu Packet"

# Download dan extract menu packet
wget -O /tmp/menu.zip "${REPO}Features/menu.zip"
unzip -o /tmp/menu.zip -d /tmp/menu

# Pindahkan dan set permission
chmod +x /tmp/menu/*
mv /tmp/menu/* /usr/local/sbin

# Bersihkan file sementara
rm -rf /tmp/menu
rm -f /tmp/menu.zip

print_success "Menu packet berhasil diinstal"