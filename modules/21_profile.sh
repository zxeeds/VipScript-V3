#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh

print_install "Setup Profile, Cron, rc.local, dan Shell"

# Setup .profile untuk user root
cat >/root/.profile <<EOF
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
mesg n || true
welcome
EOF

chmod 644 /root/.profile

# Setup cron untuk berbagai task
cat >/etc/cron.d/xp_all <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/xp
EOF

cat >/etc/cron.d/logclean <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/10 * * * * root /usr/local/sbin/clearlog
EOF

cat >/etc/cron.d/autobackup <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
5 0 * * * root backup
EOF

cat >/etc/cron.d/daily_reboot <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * root /sbin/reboot
EOF

echo "*/1 * * * * root echo -n > /var/log/nginx/access.log" >/etc/cron.d/log.nginx
echo "*/1 * * * * root echo -n > /var/log/xray/access.log" >/etc/cron.d/log.xray

service cron restart

# Setup /etc/rc.local service
cat >/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

# Setup rc.local script (disable ipv6, iptables sample)
cat >/etc/rc.local <<EOF
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
systemctl restart netfilter-persistent
exit 0
EOF

chmod +x /etc/rc.local

# Tambah shell yang diizinkan
echo "/bin/false" >>/etc/shells
echo "/usr/sbin/nologin" >>/etc/shells

systemctl daemon-reload
systemctl enable --now rc-local

print_success "Setup profile, cron, rc.local, dan shell selesai"