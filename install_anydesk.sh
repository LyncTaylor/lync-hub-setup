# Run this command to execute this script from GitHub:
# curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_anydesk.sh | sudo bash -i


#!/usr/bin/env bash

echo "🔧 Installing AnyDesk on Lync Hub..."

# Check if run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Install required packages
apt update
apt install -y ca-certificates curl apt-transport-https gnupg

# Add AnyDesk repo and key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" > /etc/apt/sources.list.d/anydesk-stable.list

# Install AnyDesk
apt update
apt install -y anydesk
systemctl enable anydesk
systemctl start anydesk

# Disable Wayland if using GDM3
if [[ -f /etc/gdm3/custom.conf ]]; then
  sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
  echo "🖥️ Wayland disabled. (Xorg will be used)"
else
  echo "⚠️ GDM3 not found, skipping Wayland configuration."
fi

# Set unattended access password
echo
read -s -p "Set AnyDesk unattended access password: " AD_PASS < /dev/tty
echo
read -s -p "Confirm password: " AD_PASS_CONFIRM < /dev/tty
echo

if [[ "$AD_PASS" != "$AD_PASS_CONFIRM" ]]; then
  echo "❌ Passwords do not match."
  exit 1
fi

if [[ ${#AD_PASS} -lt 8 ]]; then
  echo "❌ Password must be at least 8 characters."
  exit 1
fi

anydesk --set-password "$AD_PASS"
unset AD_PASS AD_PASS_CONFIRM

# Show AnyDesk ID
echo
echo "✅ AnyDesk is installed. ID: $(anydesk --get-id)"

# Reboot to apply changes
echo "🔁 Rebooting in 10 seconds..."
sleep 10
reboot
