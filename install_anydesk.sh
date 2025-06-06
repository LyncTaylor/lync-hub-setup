#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/anydesk_install.log"
mkdir -p "$(dirname "$LOG_FILE")"
log() { echo "$(date): $1" | tee -a "$LOG_FILE"; }

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root or with sudo."
  exit 1
fi

# Clean up AnyDesk APT sources only if install fails before success
cleanup() {
  log "❌ Script failed. Cleaning up AnyDesk sources..."
  if ! command -v anydesk >/dev/null 2>&1; then
    sudo rm -f /etc/apt/keyrings/keys.anydesk.com.asc
    sudo rm -f /etc/apt/sources.list.d/anydesk-stable.list
  fi
  exit 1
}
trap cleanup ERR

log "🔧 [Lync Hub] Installing AnyDesk..."

# Install required packages
log "📦 Updating apt and installing dependencies..."
if ! sudo apt update; then
  log "❌ Failed to update package index. Check your internet connection."
  exit 1
fi
sudo apt install -y ca-certificates curl apt-transport-https gnupg

# Set up AnyDesk APT repo
log "🌐 Adding AnyDesk repository..."
ANYDESK_REPO_URL="https://deb.anydesk.com"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL "${ANYDESK_REPO_URL}/repos/DEB-GPG-KEY" -o /etc/apt/keyrings/keys.anydesk.com.asc
sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] ${ANYDESK_REPO_URL} all main" |
  sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Install AnyDesk
log "📦 Installing AnyDesk..."
if ! sudo apt update; then
  log "❌ Failed to update package index after adding AnyDesk repo."
  exit 1
fi
sudo apt install -y anydesk

# Verify installation
if ! command -v anydesk >/dev/null 2>&1; then
  log "❌ AnyDesk not installed correctly."
  exit 1
fi

# Enable and start AnyDesk service
log "🔌 Enabling and starting AnyDesk service..."
sudo systemctl enable anydesk
sudo systemctl start anydesk

# Disable Wayland if using GDM3
if [[ -f /etc/gdm3/custom.conf ]]; then
  log "🖥️ Disabling Wayland (forcing Xorg)..."
  sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak
  sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
else
  log "⚠️ GDM3 not detected. Skipping Wayland disable step."
fi

# Prompt for unattended access password
echo
echo "🔐 Awaiting unattended access password (not logged)..."
read -s -p "Enter password: " AD_PASS; echo
read -s -p "Confirm password: " AD_PASS_CONFIRM; echo

if [[ "$AD_PASS" != "$AD_PASS_CONFIRM" ]]; then
  echo "❌ Passwords do not match. Exiting."
  exit 1
fi

if [[ ${#AD_PASS} -lt 8 ]]; then
  echo "❌ Password must be at least 8 characters long."
  exit 1
fi

anydesk --set-password "$AD_PASS"
unset AD_PASS AD_PASS_CONFIRM

# Show AnyDesk ID and log it
AD_ID=$(anydesk --get-id)
log "✅ AnyDesk is installed and configured."
log "🔗 AnyDesk ID: $AD_ID"

# Prompt for reboot
echo
log "✅ Setup complete."
read -p "Reboot required to apply display changes. Reboot now? [y/N]: " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
  log "🔁 Rebooting in 10 seconds..."
  sleep 10
  sudo reboot
else
  log "⚠️ Please reboot manually to apply display server changes."
fi
