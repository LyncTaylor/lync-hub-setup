#!/usr/bin/env bash
set -euo pipefail

# Must be root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root or with sudo."
  exit 1
fi

# Add AnyDesk repo and key
apt update
apt install -y ca-certificates curl apt-transport-https gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
  -o /etc/apt/keyrings/keys.anydesk.com.asc
chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" \
  | tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Install AnyDesk
apt update
apt install -y anydesk
systemctl enable anydesk
systemctl start anydesk

# Disable Wayland
sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf || true

# Set unattended access password
echo
read -s -p "Set AnyDesk password: " AD_PASS; echo
read -s -p "Confirm password: " AD_PASS_CONFIRM; echo
[[ "$AD_PASS" != "$AD_PASS_CONFIRM" ]] && echo "Passwords don't match." && exit 1
anydesk --set-password "$AD_PASS"
unset AD_PASS AD_PASS_CONFIRM

# Show ID
echo
anydesk --get-id

# Prompt reboot
echo
read -p "Reboot now to apply changes? [y/N]: " R
[[ "$R" =~ ^[Yy]$ ]] && reboot
