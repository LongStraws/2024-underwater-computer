#!/bin/bash

set -e

DWE_REPO=https://raw.githubusercontent.com/DeepwaterExploration/DWE_OS/main

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

KELPIE_REPO=https://github.com/KelpieRobotics/2024-underwater-computer/scope-1-dietPi-Fufs

echo "Installing pySerial"
pip install pyserial

echo "Installing ROV client"
apt install git python3-rpi.gpio
git clone $KELPIE_REPO /opt

echo "Installing rov client service"
ROV_SERVICE_FILE="/usr/lib/systemd/system/rov-client.service"
if [ -f "$ROV_SERVICE_FILE" ] ; then
    rm "$ROV_SERVICE_FILE"
fi
curl -fsSL $KELPIE_REPO/scripts/rov-client.service -o /usr/lib/systemd/system/rov-client.service

systemctl daemon-reload

systemctl enable dwe-controls
systemctl start dwe-controls
echo "Installation of dwe-controls with docker was successful. Please navigate to http://192.168.0.20:5000 to access the interface."

systemctl enable rov-client.service
systemctl start rov-client.service
echo "Installation of ROV client was successful. Attached to 192.168.0.21:9000 with serial port /dev/ttyACM0"
