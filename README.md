# lync-hub-setup
Scripts to set up a Lync hub

## Installing AnyDesk

To install AnyDesk on a Lync hub in one step, run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/LyncTaylor/lync-hub-setup/main/install_anydesk.sh | sudo bash -i
```

This script installs AnyDesk and configures an unattended access password.
Set the `ANYDESK_PASSWORD` environment variable before running the command to
use a pre-defined password without any prompts. If the variable is unset, you
will be asked to enter the password interactively. After installation the system
reboots to apply the changes.

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
Frigate now uses host networking. Its web interface is available on port `5000`
of the host and the service also listens on ports `8971`, `8554`, and `8555` for
RTSP and WebRTC.

Home Assistant's configuration will be stored under `/opt/lync-hub/homeassistant/config`.
Home Assistant uses host networking and runs with `privileged` mode enabled for
hardware access. Set the `TZ` environment variable in the compose file to your
timezone before starting the stack.

