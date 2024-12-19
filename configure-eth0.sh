#!/bin/bash
# Link this script on /etc/networkd-dispatcher/routable.d/ :
#  sudo ln -s /opt/scripts/configure-eth0.sh /etc/networkd-dispatcher/routable.d/10-configure-eth0.sh
#  sudo systemctl restart networkd-dispatcher

# Configuration variables
TARGET_IFACE="eth0"
TARGET_SPEED="${TARGET_SPEED:-1000}"      # Speed (100, 1000...)
TARGET_DUPLEX="${TARGET_DUPLEX:-full}"    # Duplex (full/half)
TARGET_AUTONEG="${TARGET_AUTONEG:-on}"    # Autonegociation (on/off)

# Exit if the interface is not the target
if [ "$IFACE" != "$TARGET_IFACE" ]; then
    exit 0
fi

# Log the start of the script
logger -t configure-${TARGET_IFACE} "Starting network configuration for ${TARGET_IFACE}"

# Check current settings
CURRENT_SETTINGS=$(ethtool "$TARGET_IFACE")
CURRENT_SPEED=$(echo "$CURRENT_SETTINGS" | grep Speed | awk '{print $2}' | sed 's/Mb\/s//')
CURRENT_DUPLEX=$(echo "$CURRENT_SETTINGS" | grep Duplex | awk '{print $2}')
CURRENT_AUTONEG=$(echo "$CURRENT_SETTINGS" | grep "Auto-negotiation" | awk '{print $3}')

if [ "$CURRENT_SPEED" == "$TARGET_SPEED" ] && \
   [ "$CURRENT_DUPLEX" == "$(echo $TARGET_DUPLEX | awk '{print toupper($0)}')" ] && \
   [ "$CURRENT_AUTONEG" == "$TARGET_AUTONEG" ]; then
    logger -t configure-${TARGET_IFACE} "Network configuration for ${TARGET_IFACE} is already correct!"
    exit 0
fi

# Disable Energy-Efficient Ethernet (EEE)
if ethtool --set-eee "$TARGET_IFACE" eee off; then
    logger -t configure-${TARGET_IFACE} "EEE successfully disabled on ${TARGET_IFACE}"
else
    logger -t configure-${TARGET_IFACE} "Failed to disable EEE on ${TARGET_IFACE}"
fi

# Set speed, duplex, and autonegotiation
if ethtool -s "$TARGET_IFACE" speed "$TARGET_SPEED" duplex "$TARGET_DUPLEX" autoneg "$TARGET_AUTONEG"; then
    logger -t configure-${TARGET_IFACE} "Speed, duplex, and autonegotiation configured successfully on ${TARGET_IFACE}"
else
    logger -t configure-${TARGET_IFACE} "Failed to configure speed, duplex, and autonegotiation on ${TARGET_IFACE}"
fi

# Log the end of the script
logger -t configure-${TARGET_IFACE} "Network configuration for ${TARGET_IFACE} completed"
