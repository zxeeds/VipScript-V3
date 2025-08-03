#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Finalisasi: Bersih-bersih, Info Install, dan Reboot"

# Bersihkan history dan file sampah
history -c
echo "unset HISTFILE" >> /etc/profile

rm -rf /root/menu
rm -rf /root/*.zip
rm -rf /root/*.sh
rm -rf /root/LICENSE
rm -rf /root/README.md
rm -rf /root/domain

# Tampilkan info install sukses
echo -e ""
echo -e "\033[96m_______________________________\033[0m"
echo -e "\033[92m         INSTALL SUCCES\033[0m"
echo -e "\033[96m_______________________________\033[0m"
echo -e ""
sleep 2
clear
echo -e "\033[93;1m Wait in 4 sec...\033[0m"
sleep 4
clear

# Info waktu instalasi
if [[ -n "$start" ]]; then
  secs_to_human="$(($(date +%s) - ${start}))"
  echo "Installation time : $((${secs_to_human} / 3600)) hours $(((${secs_to_human} / 60) % 60)) minute's $((${secs_to_human} % 60)) seconds"
fi

# Reboot prompt
read -p "Press [ Enter ] TO REBOOT"
reboot