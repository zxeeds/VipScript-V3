#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Enable Semua Service Utama"

# Enable semua service utama agar otomatis berjalan saat boot
systemctl enable nginx
systemctl enable xray
systemctl enable openvpn
systemctl enable ssh
systemctl enable dropbear
systemctl enable fail2ban
systemctl enable vnstat
systemctl enable haproxy
systemctl enable cron
systemctl enable netfilter-persistent
systemctl enable rc-local

# Aktifkan service (jika belum aktif)
systemctl start nginx
systemctl start xray
systemctl start openvpn
systemctl start ssh
systemctl start dropbear
systemctl start fail2ban
systemctl start vnstat
systemctl start haproxy
systemctl start cron
systemctl start netfilter-persistent
systemctl start rc-local

print_success "Semua service utama telah di-enable dan dijalankan"