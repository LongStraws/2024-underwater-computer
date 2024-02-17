![](/docs/images/kelpie_logo.png)
# Kelpie Robotics - Underwater Computer
![Kelpie Robotics](https://img.shields.io/badge/Kelpie_Robotics-Underwater_Computer-00a99d.svg?style=for-the-badge)

This script configures ubuntu on Orange pi for Kelpie.

Install [Ubuntu-rockchip on Orange Pi](https://github.com/Joshua-Riek/ubuntu-rockchip)

After user creation and login, run `sudo apt update && sudo apt upgrade -y`, accept any prompts. Then reboot and run this command:

`curl -fsSL https://raw.githubusercontent.com/KelpieRobotics/2024-underwater-computer/ubuntu-jreik/scripts/setupscript.sh | sudo -E bash -`

This will set the static IP on the pi to 192.168.137.20 on the next reboot.
