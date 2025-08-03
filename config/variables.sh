#!/bin/bash

# Variabel warna terminal
Green="\e[92;1m"
RED="\033[1;31m"
BG_RED="\033[41;97;1m"
CYAN="\033[96;1m"
NC='\033[0m'
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
red='\e[1;31m'
green='\e[0;32m"

# Variabel URL dan Telegram
TIME=$(date '+%d %b %Y')
TIMES="10"
CHATID="6838470369"
KEY="7257514557:AAEHgHjzQ5WJ5UnLfEas-o10VzoNP9FCvNU"
URL="https://api.telegram.org/bot$KEY/sendMessage"

# Variabel REPO untuk sumber script & file konfigurasi
REPO="https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/"