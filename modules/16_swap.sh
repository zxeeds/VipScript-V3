#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Setup SWAP dan BBR TCP Accelerator"

# Buat swapfile 2GB
SWAPSIZE=2G
fallocate -l $SWAPSIZE /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Tambahkan ke /etc/fstab agar aktif saat boot
if ! grep -q "/swapfile" /etc/fstab; then
  echo "/swapfile none swap sw 0 0" >> /etc/fstab
fi

# Aktifkan BBR
modprobe tcp_bbr
echo "tcp_bbr" | tee -a /etc/modules-load.d/modules.conf

sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbr

# Setup agar BBR otomatis aktif
cat >> /etc/sysctl.conf <<EOF

# BBR & fq
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

sysctl -p

print_success "SWAP & BBR berhasil diaktifkan"