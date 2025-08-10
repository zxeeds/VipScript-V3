#!/bin/bash

# Warna teks
Green="\e[92;1m"
RED="\033[1;31m"
CYAN="\033[96;1m"
NC='\033[0m'
YELLOW="\033[33m"
BLUE="\033[36m"
LIGHT="\033[0;37m"

# Fungsi untuk menampilkan pesan
function print_install() {
    echo -e "${YELLOW} ─────────────────────────────────────── ${NC}"
    echo -e "${YELLOW} # $1 ${NC}"
    echo -e "${YELLOW} ─────────────────────────────────────── ${NC}"
    sleep 1
}

function print_success() {
    if [[ 0 -eq $? ]]; then
        echo -e "${Green} ─────────────────────────────────────── ${NC}"
        echo -e "${Green} # $1 berhasil dipasang"
        echo -e "${Green} ─────────────────────────────────────── ${NC}"
        sleep 2
    fi
}

# Memeriksa apakah pengguna adalah root
if [ "${EUID}" -ne 0 ]; then
    echo "Anda harus menjalankan script ini sebagai root"
    exit 1
fi

# Memeriksa virtualisasi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ tidak didukung"
    exit 1
fi

# Memeriksa arsitektur
if [[ $( uname -m | awk '{print $1}' ) == "x86_64" ]]; then
    echo -e "Arsitektur Anda didukung ( ${Green}$( uname -m )${NC} )"
else
    echo -e "Arsitektur Anda tidak didukung ( ${YELLOW}$( uname -m )${NC} )"
    exit 1
fi

# Memeriksa OS
if [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "ubuntu" ]]; then
    echo -e "OS Anda didukung ( ${Green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
elif [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "debian" ]]; then
    echo -e "OS Anda didukung ( ${Green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
else
    echo -e "OS Anda tidak didukung ( ${YELLOW}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
    exit 1
fi

# Mendapatkan IP publik
IP=$(curl -sS ipv4.icanhazip.com)
echo -e "IP Address: ${Green}$IP${NC}"
echo ""
read -p "Tekan [Enter] untuk memulai instalasi"
echo ""
clear

# Update dan upgrade sistem
print_install "Update dan upgrade sistem"
apt update -y
apt upgrade -y
print_success "Update dan upgrade sistem"

# Instal paket dasar
print_install "Menginstall Packet Dasar"
apt install -y wget curl zip pwgen openssl netcat-openbsd socat cron bash-completion figlet 
apt install -y sudo net-tools openssl ca-certificates gnupg lsb-release nginx
apt install -y ntpdate chrony dnsutils fail2ban vnstat jq
print_success "Packet Dasar"

# Setup direktori
print_install "Membuat direktori"
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /etc/openvpn
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
print_success "Direktori"

# Setup domain
function pasang_domain() {
    clear
    echo -e "    _______________________________"
    echo -e "   |\e[1;32mPilih Jenis Domain \e[0m|"
    echo -e "    _______________________________"
    echo -e "     \e[1;32m1)\e[0m Domain Anda Sendiri"
    echo -e "     \e[1;32m2)\e[0m Domain Acak"
    echo -e "   _______________________________"
    read -p "   Pilih nomor 1-2 atau tombol lainnya (Random): " host
    echo ""
    if [[ $host == "1" ]]; then
        clear
        echo -e "   \e[1;32m      PERUBAHAN DOMAIN $NC"
        echo -e ""
        read -p "   MASUKKAN DOMAIN ANDA: " host1
        mkdir -p /var/lib/kyt
        echo "IP=" >> /var/lib/kyt/ipvps.conf
        echo $host1 > /etc/xray/domain
        echo $host1 > /root/domain
        echo ""
    elif [[ $host == "2" ]]; then
        # Gunakan script CF untuk domain acak atau ganti dengan metode lain
        DOMAIN="vpn-$(tr -dc a-z0-9 </dev/urandom | head -c5).duckdns.org"
        echo $DOMAIN > /etc/xray/domain
        echo $DOMAIN > /root/domain
        echo "Domain acak: $DOMAIN digunakan"
    else
        # Gunakan domain acak default
        DOMAIN="vpn-$(tr -dc a-z0-9 </dev/urandom | head -c5).duckdns.org"
        echo $DOMAIN > /etc/xray/domain
        echo $DOMAIN > /root/domain
        echo "Domain acak: $DOMAIN digunakan"
    fi
}

# Pasang domain
print_install "Pengaturan Domain"
mkdir -p /var/lib/kyt
pasang_domain
domain=$(cat /root/domain)
print_success "Pengaturan Domain"

# Setup SSL
function pasang_ssl() {
    print_install "Memasang SSL Pada Domain"
    rm -rf /etc/xray/xray.key
    rm -rf /etc/xray/xray.crt
    domain=$(cat /root/domain)
    STOPWEBSERVER=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
    rm -rf /root/.acme.sh
    mkdir /root/.acme.sh
    systemctl stop $STOPWEBSERVER
    systemctl stop nginx
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    chmod 777 /etc/xray/xray.key
    print_success "SSL Certificate"
}

# Pasang SSL
print_install "Pengaturan SSL"
pasang_ssl
print_success "Pengaturan SSL"

# Konfigurasi Nginx
print_install "Konfigurasi Nginx"
cat >/etc/nginx/conf.d/xray.conf <<'END'
server {
    listen 1010 proxy_protocol so_keepalive=on reuseport;
    set_real_ip_from 127.0.0.1;
    real_ip_header  proxy_protocol;
    server_name xxx;
    client_body_buffer_size 200K;
    client_header_buffer_size 2k;
    client_max_body_size 10M;
    large_client_header_buffers 3 1k;
    client_header_timeout 86400000m;
    keepalive_timeout 86400000m;
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-XSS-Protection "1; mode=block";

    location ~ /vless {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /vless break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10001;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ /vmess {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /vmess break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10002;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  } 
    location ~ /trojan-ws {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /trojan-ws break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10003;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ /ss-ws {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /ss-ws break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10004;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ / {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /fightertunnelssh break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10015;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  }
}
server {
    listen 1012 proxy_protocol so_keepalive=on reuseport;
    client_body_buffer_size 200K;
    client_header_buffer_size 2k;
    client_max_body_size 10M;
    large_client_header_buffers 3 1k;
    client_header_timeout 86400000m;
    keepalive_timeout 86400000m;
    server_name xxx;

    location ~ / {
    if ($http_upgrade != "Websocket") {
    rewrite /(.*) /fightertunnelovpn break;
    }
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:10012;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $http_x_forwarded_for;
    proxy_set_header X-Forwarded-For $http_x_forwarded_for;
  }
}
server {
    listen 81 ssl http2 reuseport;
    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    root /var/www/html;
}
server {
    listen 1013 http2 proxy_protocol so_keepalive=on reuseport;
    client_body_buffer_size 200K;
    client_header_buffer_size 2k;
    client_max_body_size 10M;
    large_client_header_buffers 3 1k;
    client_header_timeout 86400000m;
    keepalive_timeout 86400000m;
    server_name xxx;
    location ~ /vless-grpc {
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    grpc_set_header Host $host;
    grpc_pass grpc://127.0.0.1:10005;
    grpc_set_header X-Real-IP $http_x_forwarded_for;
    grpc_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ /vmess-grpc {
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    grpc_set_header Host $host;
    grpc_pass grpc://127.0.0.1:10006;
    grpc_set_header X-Real-IP $http_x_forwarded_for;
    grpc_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ /trojan-grpc {
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    grpc_set_header Host $host;
    grpc_pass grpc://127.0.0.1:10007;
    grpc_set_header X-Real-IP $http_x_forwarded_for;
    grpc_set_header X-Forwarded-For $http_x_forwarded_for;
  }
    location ~ /ss-grpc {
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
    add_header X-SERVER-LEVEL-HEADER 1;
    add_header X-LOCATION-LEVEL-HEADER 1;
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;
    proxy_http_version 1.1;
    proxy_redirect off;
    grpc_set_header Host $host;
    grpc_pass grpc://127.0.0.1:10008;
    grpc_set_header X-Real-IP $http_x_forwarded_for;
    grpc_set_header X-Forwarded-For $http_x_forwarded_for;
  }
}
END

# Konfigurasi Nginx untuk kompatibilitas Ubuntu 24
# Memeriksa versi Ubuntu
ubuntu_version=$(lsb_release -rs)

# Jika Ubuntu 24, tambahkan penyesuaian yang diperlukan untuk Nginx
if [[ "$ubuntu_version" == "24."* ]]; then
    print_install "Penyesuaian Nginx untuk Ubuntu 24"
    
    # Memastikan modul Nginx yang dibutuhkan tersedia
    apt install -y libnginx-mod-http-headers-more-filter
    
    # Sesuaikan konfigurasi jika diperlukan
    sed -i 's|# Penyesuaian|# Penyesuaian untuk Ubuntu 24|g' /etc/nginx/conf.d/xray.conf
    
    # Tambahkan line berikut jika perlu penyesuaian dengan Nginx di Ubuntu 24
    echo "# Konfigurasi dimodifikasi untuk Ubuntu 24" >> /etc/nginx/conf.d/xray.conf
fi

# Update server_name dengan domain yang aktual
sed -i "s|server_name xxx;|server_name ${domain};|g" /etc/nginx/conf.d/xray.conf

# Buat halaman default
mkdir -p /var/www/html
cat >/var/www/html/index.html <<END
<!DOCTYPE html>
<html>
<head>
    <title>VPN Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            text-align: center;
            padding: 50px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #4CAF50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>VPN Server is running!</h1>
        <p>If you're seeing this page, your VPN server is successfully installed and working.</p>
    </div>
</body>
</html>
END

systemctl restart nginx
print_success "Nginx"

# Setup SSH
print_install "Konfigurasi SSH"
# Mengubah password SSH
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/files/password"
chmod +x /etc/pam.d/common-password

# Konfigurasi SSHD
wget -q -O /etc/ssh/sshd_config "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/files/sshd"
chmod 700 /etc/ssh/sshd_config
systemctl restart ssh
print_success "SSH"

# Konfigurasi Dropbear
print_install "Menginstall Dropbear"
apt-get install dropbear -y
wget -q -O /etc/default/dropbear "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/cfg/dropbear.conf"
chmod +x /etc/default/dropbear
systemctl enable dropbear
systemctl restart dropbear
print_success "Dropbear"

# Setup timezone
timedatectl set-timezone Asia/Jakarta
systemctl enable chrony
systemctl restart chrony

# IPv6 disable
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# Setup OpenVPN
print_install "Menginstall OpenVPN"
wget "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/files/openvpn"
chmod +x openvpn
./openvpn
systemctl restart openvpn
print_success "OpenVPN"

# Setup fail2ban
print_install "Menginstall Fail2ban"
apt install fail2ban -y
echo "Banner /etc/banner.txt" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/banner.txt"@g' /etc/default/dropbear
wget -O /etc/banner.txt "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/banner/issue.net"

# Konfigurasi fail2ban untuk SSH
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 600
EOF

systemctl restart fail2ban
print_success "Fail2ban"

# Setup BBR
print_install "Memasang TCP BBR"
cat > /etc/sysctl.conf <<EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
sysctl -p
print_success "TCP BBR"

# Setup vnstat
print_install "Menginstall Vnstat"
apt -y install vnstat
systemctl restart vnstat
apt -y install libsqlite3-dev
vnstat -u -i $(ip -o -4 route show to default | awk '{print $5}')
systemctl enable vnstat
systemctl restart vnstat
print_success "Vnstat"

# Setup rc.local
cat > /etc/rc.local <<EOF
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
EOF
chmod +x /etc/rc.local

# Install Menu
print_install "Menginstall Menu VPS"
wget -q -O /tmp/menu.zip "https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/menu/menu.zip"
mkdir -p /tmp/menu
unzip -q /tmp/menu.zip -d /tmp/menu
chmod +x /tmp/menu/*
mv /tmp/menu/* /usr/local/sbin/
rm -rf /tmp/menu /tmp/menu.zip
print_success "Menu VPS"

# Final cleanup
print_install "Cleaning up"
apt autoclean -y
apt autoremove -y
print_success "Cleaning up"

# Restart semua layanan
print_install "Restarting Semua Layanan"
systemctl restart ssh
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart vnstat
systemctl restart openvpn
systemctl restart cron
systemctl restart nginx
systemctl daemon-reload
print_success "Semua Layanan"

# Buat informasi tentang port dan layanan yang berjalan
print_install "Informasi VPN"
echo -e "${CYAN}═════════════════════════════════════${NC}"
echo -e "${Green}    VPN SERVER TELAH SIAP DIGUNAKAN!   ${NC}"
echo -e "${CYAN}═════════════════════════════════════${NC}"
echo -e ""
echo -e "${Green}Domain:${NC} ${domain}"
echo -e ""
echo -e "${Green}SSH dan OpenVPN Informasi:${NC}"
echo -e "- SSH: ${Green}22${NC}"
echo -e "- Dropbear: ${Green}109, 143${NC}"
echo -e "- OpenVPN TCP: ${Green}1194${NC}"
echo -e "- OpenVPN UDP: ${Green}2200${NC}"
echo -e ""
echo -e "${Yellow}Untuk informasi lebih lanjut tentang OpenVPN credentials, cek file:${NC}"
echo -e "${Green}/root/client.ovpn${NC}"
echo -e ""
echo -e "${Yellow}Untuk mengakses menu ketik:${NC}"
echo -e "${Green}menu${NC}"
echo -e ""
echo -e "${CYAN}═════════════════════════════════════${NC}"
echo -e ""

# Hapus file instalasi
rm -f openvpn
history -c

echo "Instalasi selesai! Anda perlu reboot server."
read -p "Reboot sekarang? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    reboot
fi