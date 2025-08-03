#!/bin/bash

# Pastikan fungsi print_install dan print_success sudah di-load dari lib/utils.sh
# Pastikan variabel REPO sudah di-load dari config/variables.sh

print_install "Instalasi Rclone, Wondershaper & Setup Backup Server"

# Install rclone
curl -s https://rclone.org/install.sh | bash

# Install wondershaper untuk limit bandwidth
apt-get update -y
apt-get install -y wondershaper

# Download script backup server
wget -O /usr/bin/backup "${REPO}files/backup"
chmod +x /usr/bin/backup

# Download script auto backup (cron)
wget -O /usr/bin/autobackup "${REPO}files/autobackup"
chmod +x /usr/bin/autobackup

# Download script restore backup
wget -O /usr/bin/restore "${REPO}files/restore"
chmod +x /usr/bin/restore

# Buat folder backup
mkdir -p /root/backup

# Setup Cronjob autobackup setiap hari jam 5 pagi
(crontab -l 2>/dev/null; echo "0 5 * * * /usr/bin/autobackup") | crontab -

print_success "Instalasi rclone, wondershaper, dan backup server selesai"