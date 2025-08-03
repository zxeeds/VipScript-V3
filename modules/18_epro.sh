#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi ePro WebSocket Proxy & Setup iptables"

# Download binary ePro WebSocket Proxy
wget -O /usr/bin/ws "${REPO}files/ws"
chmod +x /usr/bin/ws

# Download konfigurasi tun.conf
wget -O /usr/bin/tun.conf "${REPO}cfg/tun.conf"
chmod 644 /usr/bin/tun.conf

# Download dan pasang systemd service untuk ePro
wget -O /etc/systemd/system/ws.service "${REPO}files/ws.service"
chmod +x /etc/systemd/system/ws.service

# Download geosite dan geoip untuk xray
wget -q -O /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -q -O /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

# Download ftvpn binary
wget -O /usr/sbin/ftvpn "${REPO}files/ftvpn"
chmod +x /usr/sbin/ftvpn

# Setup systemd service
systemctl stop ws 2>/dev/null
systemctl disable ws 2>/dev/null
systemctl enable ws
systemctl start ws

# Simpan iptables sebelum perubahan
iptables-save > /etc/iptables.backup

# Tambahkan iptables rules anti torrent & forwarding
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP || true
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP || true
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP || true
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP || true
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP || true
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP || true

# Save iptables rules
iptables-save > /etc/iptables.up.rules

# Reload netfilter-persistent
netfilter-persistent save 2>/dev/null || true
netfilter-persistent reload 2>/dev/null || true

# Bersihkan cache dan file yang tidak perlu
apt autoclean -y
apt autoremove -y

print_success "Instalasi ePro WebSocket Proxy & rules iptables selesai"