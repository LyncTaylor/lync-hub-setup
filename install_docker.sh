#!/usr/bin/env bash
# Run this command to execute this script from GitHub:
#   curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_docker.sh | sudo bash -i

set -e

if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

echo "🔧 Installing Docker..."

apt-get update
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ${SUDO_USER:-$USER}

mkdir -p /opt/lync-hub
curl -fsSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/docker-compose.yml -o /opt/lync-hub/docker-compose.yml

echo "✅ Docker installed. Compose file saved to /opt/lync-hub/docker-compose.yml"
echo "Run 'docker compose -f /opt/lync-hub/docker-compose.yml up -d' to start services."
