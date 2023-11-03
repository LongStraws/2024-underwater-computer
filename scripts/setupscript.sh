#!/bin/bash

set -e

SETUP_REPO=https://raw.githubusercontent.com/KelpieRobotics/2024-underwater-computer/scope-1-ubuntu

apt-get update && apt-get upgrade -y

echo 0

curl -fsSL https://raw.githubusercontent.com/DeepwaterExploration/DWE_OS/main/scripts/install-docker.sh | bash -

echo 1

curl -fsSL --output-dir /opt --remote-name-all $SETUP_REPO/clientClass.py $SETUP_REPO/uart.py

echo 2

client_service_file="/usr/lib/systemd/system/rov-client.service"
if [ -f "$client_service_file" ] ; then
    rm "$client_service_file"
fi

curl -fsSL $SETUP_REPO/scripts/rov-client.service -o /usr/lib/systemd/system/rov-client.service

echo 3

curl -fsSL $SETUP_REPO/scripts/60_static_config.yaml -o /etc/netplan/60_static_config.yaml

echo 4

echo -e "dtoverlay=disable-wifi\ndtoverlay=disable-bt\n[all]" >> /boot/firmware/config.txt

systemctl daemon-reload
systemctl enable rov-client.service
systemctl start rov-client.service

systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
systemctl disable snap.lxd.activate.service
systemctl disable apparmor
systemctl disable snapd.apparmor.service
systemctl mask snapd.service

systemctl disable hciuart
systemctl disable iscsi.service

touch /etc/cloud/cloud-init.disabled

echo "Done. Upon next reboot system will have ip 192.168.0.20."
