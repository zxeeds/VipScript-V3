#!/bin/bash

# Pastikan fungsi print_install sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Konfigurasi Domain untuk Xray"

echo -e ""
clear
echo -e "    _______________________________"
echo -e "   |\e[1;32mSilakan Pilih Jenis Domain di bawah \e[0m|"
echo -e "    _______________________________"
echo -e "     \e[1;32m1)\e[0m Domain Sendiri (Manual Input)"
echo -e "     \e[1;32m2)\e[0m Random Domain/Subdomain Otomatis"
echo -e "   _______________________________"
read -p "   Pilih angka 1-2 atau tombol lain untuk Random: " host
echo ""

if [[ "$host" == "1" ]]; then
  clear
  echo -e "   \e[1;36m_______________________________${NC}"
  echo -e "   \e[1;32m      GANTI DOMAIN $NC"
  echo -e "   \e[1;36m_______________________________${NC}"
  echo ""
  read -p "   Masukkan Domain Anda : " host1
  echo "IP=" >> /var/lib/kyt/ipvps.conf
  echo "$host1" > /etc/xray/domain
  echo "$host1" > /root/domain
  echo ""
elif [[ "$host" == "2" ]]; then
  wget ${REPO}files/cf.sh && chmod +x cf.sh && ./cf.sh
  # Hasil domain random akan ditulis ke /etc/xray/domain dan /root/domain oleh cf.sh
  rm -f cf.sh
  clear
else
  print_install "Random Subdomain/Domain digunakan"
  wget ${REPO}files/cf.sh && chmod +x cf.sh && ./cf.sh
  rm -f cf.sh
  clear
fi