#!/bin/bash

set -e

DWE_REPO=https://raw.githubusercontent.com/DeepwaterExploration/DWE_OS/main

echo "Installing docker if not already installed"
docker --version || curl -fsSL https://get.docker.com/ | sh
systemctl enable docker

# Pull DWE-controls docker image
echo "Pulling DWE-controls docker image"
docker pull brandondwe/dwe-controls

# Create DWE-controls docker container
echo "Creating DWE-controls docker container"
if [ "$(docker ps -q -f name=dwe-controls)" ]; then
    docker rm dwe-controls --force
fi
docker create \
    --name dwe-controls \
    --net=host \
    -v /dev:/dev -v /dwe/.dwe:/root/.dwe -v /run/udev:/run/udev \
    --privileged brandondwe/dwe-controls

echo "Installing DWE-OS service"
DWE_SERVICE_FILE="/usr/lib/systemd/system/dwe-controls.service"
if [ -f "$DWE_SERVICE_FILE" ] ; then
    rm "$DWE_SERVICE_FILE"
fi
curl -fsSL $DWE_REPO/docker/dwe-controls.service -o /usr/lib/systemd/system/dwe-controls.service

KELPIE_REPO=https://raw.githubusercontent.com/KelpieRobotics/2024-underwater-computer/scope-1-ubuntu

echo "Installing ROV client"
curl -fsSL --output-dir /opt --remote-name-all $KELPIE_REPO/clientClass.py $KELPIE_REPO/uart.py

echo "Installing rov client service"
ROV_SERVICE_FILE="/usr/lib/systemd/system/rov-client.service"
if [ -f "$ROV_SERVICE_FILE" ] ; then
    rm "$ROV_SERVICE_FILE"
fi
curl -fsSL $KELPIE_REPO/scripts/rov-client.service -o /usr/lib/systemd/system/rov-client.service

echo "Setting static IP"
curl -fsSL $KELPIE_REPO/scripts/60_static_config.yaml -o /etc/netplan/60_static_config.yaml

systemctl daemon-reload

systemctl enable dwe-controls
systemctl start dwe-controls
echo "Installation of dwe-controls with docker was successful. Please navigate to http://192.168.0.20:5000 to access the interface."

systemctl enable rov-client.service
systemctl start rov-client.service
echo "Installation of ROV client was successful. Attached to 192.168.0.21:9000 with serial port /dev/ttyACM0"

CONFIG_FILE=/boot/firmware/config.txt
CONFIG_STRING="dtoverlay=disable-wifi
dtoverlay=disable-bt
[all]"

echo "Disabling wifi and bluetooth"
if ! grep -q "$CONFIG_STRING" $CONFIG_FILE; then
    echo -e "$CONFIG_STRING" >> $CONFIG_FILE
fi

echo "Disabling services to speed up boot"
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
systemctl disable snap.lxd.activate.service
systemctl disable apparmor
systemctl disable snapd.apparmor.service
systemctl mask snapd.service

systemctl disable hciuart

if [ -f "/etc/systemd/system/iscsi.service." ] ; then
    systemctl disable iscsi.service
fi

touch /etc/cloud/cloud-init.disabled

echo "Done. Upon next reboot system will have ip 192.168.0.20."
