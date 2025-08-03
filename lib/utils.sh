#!/bin/bash

# Warna terminal
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
green='\e[0;32m'

# Fungsi print untuk status proses
print_ok() {
  echo -e "${OK} ${BLUE} $1 ${FONT}"
}

print_error() {
  echo -e "${ERROR} ${REDBG} $1 ${FONT}"
}

print_install() {
  echo -e "${green} ─────────────────────────────────────── ${FONT}"
  echo -e "${YELLOW} # $1 ${FONT}"
  echo -e "${green} ─────────────────────────────────────── ${FONT}"
  sleep 1
}

print_success() {
  if [[ 0 -eq $? ]]; then
    echo -e "${green} ─────────────────────────────────────── ${FONT}"
    echo -e "${Green} # $1 berhasil dipasang"
    echo -e "${green} ─────────────────────────────────────── ${FONT}"
    sleep 2
  fi
}