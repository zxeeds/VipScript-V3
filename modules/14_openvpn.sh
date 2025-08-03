#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi & Setup OpenVPN"

# Install OpenVPN dan Easy-RSA
apt-get update -y
apt-get install -y openvpn easy-rsa

# Buat direktori Easy-RSA
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# Set variabel Easy-RSA
export EASYRSA_BATCH=1
export EASYRSA_REQ_CN="VPN Server"

# Inisialisasi PKI dan buat CA, server cert, Diffie-Hellman
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass
./easyrsa gen-crl

# Copy file ke folder OpenVPN
cp pki/ca.crt pki/dh.pem pki/crl.pem /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/client1.key /etc/openvpn/
cp pki/issued/client1.crt /etc/openvpn/

# Download dan pasang konfigurasi server/client
wget -O /etc/openvpn/server.conf "${REPO}files/server.conf"
wget -O /etc/openvpn/client.ovpn "${REPO}files/client.ovpn"

# Enable & restart OpenVPN
systemctl enable openvpn@server
systemctl restart openvpn@server

print_success "Instalasi & konfigurasi OpenVPN selesai"