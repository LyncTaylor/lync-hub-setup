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

The compose file expects a Frigate configuration in `frigate/config/config.yml`.
The sample configuration is set up to use a Coral USB accelerator for detections.
Clips and recordings are stored under `/opt/lync-hub/frigate/media`.
Update the `FRIGATE_RTSP_PASSWORD` environment variable in the compose file with
your RTSP password before starting the stack.

Home Assistant's configuration will be stored under `/opt/lync-hub/homeassistant/config`.
The container uses host networking and runs with `privileged` mode enabled for
hardware access. Set the `TZ` environment variable in the compose file to your
timezone before starting the stack.
