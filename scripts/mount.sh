#!/bin/bash

# Replace with the actual user and hostname/IP
SSH_HOST="moses-admin@52.166.64.63"
SSH_KEY="moseskey"

ssh -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_HOST << 'EOF'
sudo pvcreate /dev/sdc
sudo vgcreate data /dev/sdc
sudo lvcreate -n phpapp -L 5G data
sudo mkfs.ext4 /dev/data/phpapp
sudo mount /dev/data/phpapp /mnt/var/www/html/
echo "/dev/data/phpapp /mnt/var/www/html/ ext4 defaults 0 0" | sudo tee -a /etc/fstab
EOF