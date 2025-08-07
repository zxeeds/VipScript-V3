#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Mengatur Password SSH dan Konfigurasi Keyboard"

# Pasang file password PAM custom
wget -O /etc/pam.d/common-password "${REPO}files/password"
chmod +x /etc/pam.d/common-password

# Konfigurasi keyboard (non-interaktif)
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration 2>&1 | tee /var/log/keyboard-config.log
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/altgr select The default for the keyboard layout"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/compose select No compose key"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/ctrl_alt_bksp boolean false"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layoutcode string de"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layout select English"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/modelcode string pc105"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/model select Generic 105-key (Intl) PC"
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variantcode string "
debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variant select English"

# Setup rc-local untuk disable IPv6 dan konfigurasi zona waktu
cat > /etc/systemd/system/rc-local.service <<-END
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
END

cat > /etc/rc.local <<-END
#!/bin/bash
echo "rc.local executed at $(date)" >> /var/log/rc-local.log
exit 0
END

chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local || echo "rc-local failed to start. Check logs."

# Disable IPv6 secara permanen
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Set zona waktu
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# Nonaktifkan AcceptEnv pada SSH
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
systemctl restart ssh || echo "SSH service failed to restart. Check logs."

print_success "Konfigurasi Password SSH dan Keyboard selesai"