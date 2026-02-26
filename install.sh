#!/bin/bash

set -e

echo "Installing wifi-reconnect..."

# Copy script
sudo cp wifi-reconnect.sh /usr/local/bin/wifi-reconnect.sh
sudo chmod +x /usr/local/bin/wifi-reconnect.sh

# Copy systemd units
sudo cp wifi-reconnect.service /etc/systemd/system/wifi-reconnect.service
sudo cp wifi-reconnect.timer /etc/systemd/system/wifi-reconnect.timer

# Create log file
sudo touch /var/log/wifi-reconnect.log

# Enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable wifi-reconnect.timer
sudo systemctl start wifi-reconnect.timer

echo ""
echo "✅ Done! WiFi watchdog is now active."
echo ""
echo "Useful commands:"
echo "  View live logs:    journalctl -u wifi-reconnect.service -f"
echo "  View event log:    tail -f /var/log/wifi-reconnect.log"
echo "  Check timer:       systemctl status wifi-reconnect.timer"
echo "  Stop service:      sudo systemctl disable --now wifi-reconnect.timer"
