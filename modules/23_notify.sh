#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Kirim Notifikasi Install ke Telegram"

# Variabel Telegram
TIME=$(date '+%d %b %Y')
TIMEZONE=$(printf '%(%H:%M:%S)T')
CHATID="6838470369"
KEY="7257514557:AAEHgHjzQ5WJ5UnLfEas-o10VzoNP9FCvNU"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TIMES="10"

# Informasi VPS
domain=$(cat /etc/xray/domain 2>/dev/null)
ipsaya=$(wget -qO- ipinfo.io/ip)
USRSC=$(curl -s https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/REGIST | grep $ipsaya | awk '{print $2}')
EXPSC=$(curl -s https://raw.githubusercontent.com/zxeeds/VipScript-V3/main/REGIST | grep $ipsaya | awk '{print $3}')

TEXT="
<code>────────────────────</code>
<b> 🟢 NOTIFICATIONS INSTALL 🟢</b>
<code>────────────────────</code>
<code>ID     : </code><code>$USRSC</code>
<code>Domain : </code><code>$domain</code>
<code>Date   : </code><code>$TIME</code>
<code>Time   : </code><code>$TIMEZONE</code>
<code>Ip vps : </code><code>$ipsaya</code>
<code>Exp Sc : </code><code>$EXPSC</code>
<code>────────────────────</code>
<i>Automatic Notification from Github</i>
"'&reply_markup={"inline_keyboard":[[{"text":"ᴏʀᴅᴇʀ","url":"https://t.me/sannpro"},{"text":"Contack","url":"https://wa.me/085943630656"}]]}'

curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null

print_success "Notifikasi Telegram berhasil dikirim"