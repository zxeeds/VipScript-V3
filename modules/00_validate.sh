#!/bin/bash

# Pastikan fungsi print_install dan print_error sudah di-load dari lib/utils.sh

print_install "Validasi Awal Sistem"

# 1. Validasi Root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Script harus dijalankan sebagai root!"
    exit 1
fi

# 2. Validasi Arsitektur
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m Arsitektur tidak didukung ($ARCH). Hanya x86_64 yang didukung."
    exit 1
fi

# 3. Validasi OS
OS_ID=$(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g')
PRETTY_NAME=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g')

if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    echo -e "\033[92m[OK]\033[0m OS didukung ($PRETTY_NAME)"
else
    echo -e "\033[1;31m[ERROR]\033[0m OS tidak didukung ($PRETTY_NAME)"
    exit 1
fi

# 4. Validasi IP
IP=$(wget -qO- ipinfo.io/ip)
if [[ -z "$IP" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m IP Address tidak terdeteksi"
    exit 1
else
    echo -e "\033[92m[OK]\033[0m IP Address: $IP"
fi

# 5. Validasi Virtualisasi
VIRT=$(systemd-detect-virt)
if [[ "$VIRT" == "openvz" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m OpenVZ tidak didukung"
    exit 1
else
    echo -e "\033[92m[OK]\033[0m Virtualisasi: $VIRT"
fi

print_install "Validasi awal selesai. Sistem siap instalasi."