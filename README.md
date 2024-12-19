# rasp-fix-eth0

This Bash script configures the network settings of the eth0 interface on a Linux machine. It is designed to work with networkd-dispatcher to automatically apply network settings when the interface reaches the routable state.
This script was created to address an issue where my network card defaulted to 100Mbps during the boot process due to a side effect on my Raspberry Pi 4/Ubuntu server 20.04. My switch does not allow disabling auto-negotiation, and the speed/duplex settings can only be configured when auto-negotiation is turned off.
I did not want to change the network renderer.

## 📋 Features
### Variables

This script allows for flexible network configuration using environment variables:
- TARGET_IFACE: The target network interface to configure (default is eth0).
- TARGET_SPEED: The network speed to set in Mbps. Accepted values include 100, 1000, etc. The default value is 100.
- TARGET_DUPLEX: The duplex mode for the connection. Possible values are full (default) or half.
- TARGET_AUTONEG: Enable or disable autonegotiation. Possible values are on (default) or off.

You can set these environment variables in the command line before running the script, or define them in an environment file if your system uses one.
- Example 1: Set variables via command line
  ```ssh
  TARGET_IFACE="eth1" TARGET_SPEED="1000" TARGET_DUPLEX="full" TARGET_AUTONEG="on" ./configure-network.sh
  ```

- Example 2: Add variables to an environment file
  Create a file named .env:
  ```ssh
  TARGET_IFACE="eth0"
  TARGET_SPEED="100"
  TARGET_DUPLEX="full"
  TARGET_AUTONEG="off"
  ```
  Then, run the script after sourcing the variables:
  ```ssh
  source .env
  ./configure-network.sh
  ```

### Default Behavior

If no environment variables are set, the script will use the following default values:
- Interface: eth0
- Speed: 1000 Mbps
- Duplex: Full
- Autonegotiation: On

This ensures that the script will work without prior configuration, while still allowing for advanced customization if needed.

- Existing Settings Check
- If the parameters are correct, the script exits without making any changes.
- Else:
  - Disable Energy-Efficient Ethernet (EEE): To avoid potential performance issues, EEE is disabled.
  - Network Configuration:
    If necessary, the script sets the following:
        Speed to 1000Mb/s
        Duplex mode to Full
        Auto-negotiation to On

  - Logging:
  Actions taken by the script are logged to the system journal using logger for easy monitoring.


## ⚠️ Disclaimer

This script is not intended to replace existing tools but to fix specific issues with network settings.
Before using this script, ensure that:
- The network card, port, and switch support gigabit speeds.
- You have tested the script in a controlled environment before deploying it in production.

## 🛠️ Installation

Place the script in a directory such as /opt/scripts/ (or any other desired location):
```ssh
sudo cp configure-eth0.sh /opt/scripts/configure-eth0.sh
sudo chmod +x /opt/scripts/configure-eth0.sh
```

To ensure networkd-dispatcher runs the script, create a symbolic link in /etc/networkd-dispatcher/routable.d/:
```ssh
sudo ln -s /opt/scripts/configure-eth0.sh /etc/networkd-dispatcher/routable.d/10-configure-eth0.sh
```

Verify:
Ensure networkd-dispatcher is active and configured to manage network interfaces:
```ssh
systemctl status networkd-dispatcher
```

## 🚀 Usage

The script runs automatically when the eth0 interface reaches the routable state. It:
- Checks if the network settings are already correct.
- Applies necessary adjustments if required.

Logs for the script execution can be viewed using:
```ssh
journalctl -t configure-eth0
```

## 📝 Requirements

Linux with systemd-networkd and networkd-dispatcher installed.
The ethtool utility must be installed:
```ssh
sudo apt install ethtool
```

## ⚙️ Example Log Output
```
Jun 12 12:00:00 myhost configure-eth0: Starting network configuration for eth0
Jun 12 12:00:00 myhost configure-eth0: EEE successfully disabled on eth0
Jun 12 12:00:00 myhost configure-eth0: Speed and duplex configured successfully on eth0
Jun 12 12:00:00 myhost configure-eth0: Network configuration for eth0 completed
```

## 🧩 Dependencies

- networkd-dispatcher: To execute scripts based on network states.
- ethtool: To configure and validate network parameters.

## 📜 License

This script is distributed under the GPL License. See the LICENSE file for more details.
