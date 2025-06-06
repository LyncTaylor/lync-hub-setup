#!/usr/bin/env bash
set -euo pipefail

echo "🔧 [Lync Hub] Installing AnyDesk..."

# 1. Install required packages
sudo apt update
sudo apt install -y ca-certificates curl apt-transport-https gnupg

# 2. Set up AnyDesk APT repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
     -o /etc/apt/keyrings/keys.anydesk.com.asc
sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc

echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" |
  sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# 3. Install AnyDesk
sudo apt update
sudo apt install -y anydesk

# 4. Enable and start AnyDesk service
sudo systemctl enable anydesk
sudo systemctl start anydesk

# 5. Disable Wayland to ensure Xorg is used (better compatibility with AnyDesk)
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf

# 6. Prompt for unattended access password
echo
echo "🔐 Set the unattended access password for this Lync Hub:"
read -s -p "Enter password: " AD_PASS; echo
read -s -p "Confirm password: " AD_PASS_CONFIRM; echo

if [[ "$AD_PASS" != "$AD_PASS_CONFIRM" ]]; then
  echo "❌ Passwords do not match. Exiting."
  exit 1
fi

anydesk --set-password "$AD_PASS"

# 7. Show AnyDesk ID
echo
echo "✅ AnyDesk is installed and configured."
anydesk --get-id

echo
echo "✅ Setup complete. Rebooting in 10 seconds to apply display server changes..."
sleep 10
sudo reboot
