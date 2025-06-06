# Run this on a new Lync Hub:
# curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_anydesk.sh | sudo bash

#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing AnyDesk on Lync Hub..."

# Ensure we're root
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run with sudo or as root."
  exit 1
fi

# Install dependencies
apt update
apt install -y ca-certificates curl apt-transport-https gnupg

# Add AnyDesk GPG key and repo
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | tee /etc/apt/keyrings/anydesk.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] https://deb.anydesk.com all main" \
  > /etc/apt/sources.list.d/anydesk-stable.list

# Install AnyDesk
apt update
apt install -y anydesk
systemctl enable anydesk
systemctl start anydesk

# Disable Wayland for GDM3 (Xorg required for remote access)
if [[ -f /etc/gdm3/custom.conf ]]; then
  sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
  echo "🖥️ Wayland disabled (Xorg will be used)."
else
  echo "⚠️ GDM3 not found; skipping Wayland step."
fi

# Prompt for unattended access password
echo
read -s -p "Set AnyDesk unattended access password: " AD_PASS; echo
read -s -p "Confirm password: " AD_PASS_CONFIRM; echo
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

# Show ID
echo
echo "✅ AnyDesk installed. ID: $(anydesk --get-id)"

# Auto reboot to apply display server change
echo "🔁 Rebooting in 10 seconds..."
sleep 10
reboot
