#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Instalasi & Konfigurasi VnStat (Monitoring Traffic)"

# Install vnstat dan vnstati
apt-get update -y
apt-get install -y vnstat vnstati

# Restart dan enable service vnstat
systemctl restart vnstat
systemctl enable vnstat

# Setup database untuk semua interface yang aktif
for iface in $(ls /sys/class/net | grep -v lo); do
    vnstat --add -i "$iface"
done

# Update database dan generate grafik vnstati (per hari)
vnstat -u -i eth0
vnstati -d -i eth0 -o /usr/share/nginx/html/vnstat.png

print_success "Instalasi & setup VNStat selesai"