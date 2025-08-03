#!/bin/bash

REPO_RAW="https://raw.githubusercontent.com/zxeeds/VipScript-V3/main"

INSTALL_DIR="/root/VipScript-V3"
MODULES=(
  00_validate.sh
  01_first_setup.sh
  02_nginx.sh
  03_base_package.sh
  04_make_folder_xray.sh
  05_domain.sh
  06_ssl.sh
  07_install_xray.sh
  08_ssh.sh
  09_udp_mini.sh
  10_slowdns.sh
  11_sshd.sh
  12_dropbear.sh
  13_vnstat.sh
  14_openvpn.sh
  15_backup.sh
  16_swap.sh
  17_fail2ban.sh
  18_epro.sh
  19_restart.sh
  20_menu.sh
  21_profile.sh
  22_enable_services.sh
  23_notify.sh
  24_finalize.sh
)

# Buat folder
mkdir -p "$INSTALL_DIR/modules" "$INSTALL_DIR/lib" "$INSTALL_DIR/config"

# Download install.sh
wget -O "$INSTALL_DIR/install.sh" "$REPO_RAW/install.sh"

# Download file variable dan utils
wget -O "$INSTALL_DIR/config/variables.sh" "$REPO_RAW/config/variables.sh"
wget -O "$INSTALL_DIR/lib/utils.sh" "$REPO_RAW/lib/utils.sh"

# Download semua modul
for m in "${MODULES[@]}"; do
  wget -O "$INSTALL_DIR/modules/$m" "$REPO_RAW/modules/$m"
done

cd "$INSTALL_DIR" || exit 1

chmod +x install.sh
bash install.sh