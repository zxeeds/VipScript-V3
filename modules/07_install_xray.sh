#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi Core Xray dan Konfigurasi Service"

# Buat folder socket untuk domain
domainSock_dir="/run/xray"
[ ! -d "$domainSock_dir" ] && mkdir "$domainSock_dir"
chown www-data:www-data "$domainSock_dir"

# Ambil versi terbaru dari Github Xray-core
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"

# Install Xray menggunakan script resmi
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version "$latest_version"

# Download konfigurasi Xray dan service
wget -O /etc/xray/config.json "${REPO}cfg/config.json" >/dev/null 2>&1
wget -O /etc/systemd/system/runn.service "${REPO}files/runn.service" >/dev/null 2>&1

domain=$(cat /etc/xray/domain)
IPVS=$(cat /etc/xray/ipvps)

# Informasi lokasi dan ISP
curl -s ipinfo.io/city >> /etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /etc/xray/isp

print_install "Memasang Konfigurasi haproxy & nginx untuk Xray"
wget -O /etc/haproxy/haproxy.cfg "${REPO}cfg/haproxy.cfg" >/dev/null 2>&1
wget -O /etc/nginx/conf.d/xray.conf "${REPO}cfg/xray.conf" >/dev/null 2>&1
sed -i "s/xxx/${domain}/g" /etc/haproxy/haproxy.cfg
sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/xray.conf
curl "${REPO}cfg/nginx.conf" > /etc/nginx/nginx.conf

# Gabungkan sertifikat SSL untuk haproxy
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/hap.pem

chmod +x /etc/systemd/system/runn.service
rm -rf /etc/systemd/system/xray.service.d

# Buat service systemd untuk Xray
cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

print_success "Core Xray versi $latest_version dan service selesai dipasang"

# Reload dan aktifkan service
systemctl daemon-reload
systemctl enable xray
systemctl restart xray