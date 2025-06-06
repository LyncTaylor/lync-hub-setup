# lync-hub-setup
Scripts to set up a Lync hub

## Installing AnyDesk

To install AnyDesk on a Lync hub in one step, run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_anydesk.sh | sudo bash -i
```

This script installs AnyDesk, prompts you to set an unattended access password,
and reboots the system to apply the changes.

## Installing Docker and base services

Run the following command to install Docker and download the base `docker-compose.yml` file:

```bash
curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_docker.sh | sudo bash -i
```

After the script finishes you can start the services with:

```bash
docker compose -f /opt/lync-hub/docker-compose.yml up -d
```
