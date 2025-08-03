#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi dan Konfigurasi UDP Mini (Limit Quota)"

# Install script limit quota
wget -q "${REPO}files/limit.sh" -O limit.sh
chmod +x limit.sh
./limit.sh

# Install binary untuk limit-ip
wget -q -O /usr/bin/limit-ip "${REPO}files/limit-ip"
chmod +x /usr/bin/limit-ip
sed -i 's/\r//' /usr/bin/limit-ip

# Setup systemd service untuk vmip, vlip, trip
cat >/etc/systemd/system/vmip.service << EOF
[Unit]
Description=LimitIP VMESS
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip vmip
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/vlip.service << EOF
[Unit]
Description=LimitIP VLESS
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip vlip
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/trip.service << EOF
[Unit]
Description=LimitIP TROJAN
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip trip
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now vmip
systemctl enable --now vlip
systemctl enable --now trip

# Install udp-mini binary dan service
mkdir -p /usr/local/kyt/
wget -q -O /usr/local/kyt/udp-mini "${REPO}files/udp-mini"
chmod +x /usr/local/kyt/udp-mini

wget -q -O /etc/systemd/system/udp-mini-1.service "${REPO}files/udp-mini-1.service"
wget -q -O /etc/systemd/system/udp-mini-2.service "${REPO}files/udp-mini-2.service"
wget -q -O /etc/systemd/system/udp-mini-3.service "${REPO}files/udp-mini-3.service"

systemctl enable --now udp-mini-1
systemctl enable --now udp-mini-2
systemctl enable --now udp-mini-3

print_success "Instalasi dan konfigurasi UDP Mini & Limit Quota selesai"