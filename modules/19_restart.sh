#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Restart Semua Service Utama"

# Restart semua service utama
systemctl restart nginx
systemctl restart xray
systemctl restart openvpn
systemctl restart ssh
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart vnstat
systemctl restart haproxy
systemctl restart cron
systemctl restart netfilter-persistent

# Enable agar service otomatis berjalan saat boot
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

print_success "Semua service utama berhasil direstart dan di-enable"