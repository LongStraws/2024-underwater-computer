![](/docs/images/kelpie_logo.png)
# Kelpie Robotics - Underwater Computer
![Kelpie Robotics](https://img.shields.io/badge/Kelpie_Robotics-Underwater_Computer-00a99d.svg?style=for-the-badge)

This script configures ubuntu on raspberry pi with needed software for Kelpie 2024 scope 1.

Install [Ubuntu on raspberry pi](https://ubuntu.com/download/raspberry-pi/thank-you?version=23.10&architecture=server-arm64+raspi)

After user creation and login, run `sudo apt update && sudo apt upgrade -y`, accept any prompts. Then reboot and enter this in bash:

`curl https://raw.githubusercontent.com/KelpieRobotics/2024-underwater-computer/scope-1-ubuntu/scripts/setupscript.sh | sudo -E bash -`

This will set the static IP on the pi to 192.168.0.20 on the next reboot.
