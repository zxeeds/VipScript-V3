#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi Modul SlowDNS Server"

# Download dan jalankan installer SlowDNS
wget -q -O /tmp/nameserver "${REPO}files/nameserver"
chmod +x /tmp/nameserver
bash /tmp/nameserver | tee /root/install.log

print_success "Instalasi SlowDNS selesai"