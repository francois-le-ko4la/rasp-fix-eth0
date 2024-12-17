#!/bin/bash
# Link this script on /etc/networkd-dispatcher/routable.d/ :
#  sudo ln -s /opt/scripts/configure-eth0.sh /etc/networkd-dispatcher/routable.d/10-configure-eth0.sh

# Log the start of the script
logger -t configure-eth0 "Starting network configuration for eth0"

if [ "$IFACE" = "eth0" ]; then
    CURRENT_SETTINGS=$(ethtool eth0)
    CURRENT_SPEED=$(echo "$CURRENT_SETTINGS" | grep Speed | awk '{print $2}')
    CURRENT_DUPLEX=$(echo "$CURRENT_SETTINGS" | grep Duplex | awk '{print $2}')
    if [ "$CURRENT_SPEED" == "1000Mb/s" ] && [ "$CURRENT_DUPLEX" == "Full" ]; then
        logger -t configure-eth0 "Network configuration for eth0 is already correct !"
        exit 0
    fi
fi

# Disable Energy-Efficient Ethernet (EEE)
if ethtool --set-eee eth0 eee off; then
    logger -t configure-eth0 "EEE successfully disabled on eth0"
else
    logger -t configure-eth0 "Failed to disable EEE on eth0"
fi

# Set speed, duplex, and autonegotiation
if ethtool -s eth0 speed 1000 duplex full autoneg on; then
    logger -t configure-eth0 "Speed and duplex configured successfully on eth0"
else
    logger -t configure-eth0 "Failed to configure speed and duplex on eth0"
fi

# Log the end of the script
logger -t configure-eth0 "Network configuration for eth0 completed"
