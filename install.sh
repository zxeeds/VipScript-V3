#!/bin/bash

set -e

source config/variables.sh
source lib/utils.sh

source modules/00_validate.sh
source modules/01_first_setup.sh
source modules/02_nginx.sh
source modules/03_base_package.sh
source modules/04_make_folder_xray.sh
source modules/05_domain.sh
source modules/06_ssl.sh
source modules/07_install_xray.sh
source modules/08_ssh.sh
source modules/09_udp_mini.sh
source modules/10_slowdns.sh
source modules/11_sshd.sh
source modules/12_dropbear.sh
source modules/13_vnstat.sh
source modules/14_openvpn.sh
source modules/15_backup.sh
source modules/16_swap.sh
source modules/17_fail2ban.sh
source modules/18_epro.sh
source modules/19_restart.sh
source modules/20_menu.sh
source modules/21_profile.sh
source modules/22_enable_services.sh
source modules/23_notify.sh
source modules/24_finalize.sh