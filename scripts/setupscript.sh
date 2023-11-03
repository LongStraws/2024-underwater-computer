#!/bin/bash

SETUP_REPO=https://raw.githubusercontent.com/KelpieRobotics/2024-underwater-computer/scope-1-ubuntu

set -e

apt-get update && apt-get upgrade -y

systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
systemctl disable snap.lxd.activate.service
systemctl disable apparmor
systemctl disable snapd.apparmor.service
systemctl mask snapd.service

systemctl disable iscsi.service

touch /etc/cloud/cloud-init.disabled

echo -e "dtoverlay=disable-wifi\ndtoverlay=disable-bt\n[all]" >> /boot/firmware/config.txt

systemctl disable hciuart

curl -fsSL https://raw.githubusercontent.com/DeepwaterExploration/DWE_OS/main/scripts/install-docker.sh | bash -

curl --output-dir /opt --remote-name-all $SETUP_REPO/clientClass.py $SETUP_REPO/uart.py

client_service_file="/usr/lib/systemd/system/rov-client.service"
if [ -f "$client_service_file" ] ; then
    rm "$client_service_file"
fi

curl $REPO/scripts/rov-client.service -o /usr/lib/systemd/system/rov-client.service

curl $REPO/scripts/60_static_config.yaml -o /etc/netplan/60_static_config.yaml

systectl daemon-reload
systemctl enable rov-client.service
systemctl start rov-client.service

echo "Done. Upon next reboot system will have ip 192.168.0.20."
