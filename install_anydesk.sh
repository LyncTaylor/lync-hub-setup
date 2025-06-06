# Install dependencies
sudo apt update
sudo apt install -y ca-certificates curl apt-transport-https gnupg

# Add AnyDesk GPG key and APT repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
    -o /etc/apt/keyrings/keys.anydesk.com.asc
sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" |
    sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Install AnyDesk
sudo apt update
sudo apt install -y anydesk

# Start and enable service
sudo systemctl enable anydesk
sudo systemctl start anydesk

# Set password for unattended access
echo
echo "🔐 Set the unattended access password for this Lync Hub:"
read -s -p "Enter password: " AD_PASS; echo
read -s -p "Confirm password: " AD_PASS_CONFIRM; echo

if [[ "$AD_PASS" != "$AD_PASS_CONFIRM" ]]; then
  echo "❌ Passwords do not match. Exiting."
  exit 1
fi

anydesk --set-password "$AD_PASS"

# Show AnyDesk ID
echo
echo "✅ AnyDesk is installed and configured."
anydesk --get-id
