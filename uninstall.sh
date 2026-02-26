#!/bin/bash

echo "Removing wifi-reconnect..."

sudo systemctl disable --now wifi-reconnect.timer 2>/dev/null || true
sudo systemctl disable --now wifi-reconnect.service 2>/dev/null || true

sudo rm -f /etc/systemd/system/wifi-reconnect.service
sudo rm -f /etc/systemd/system/wifi-reconnect.timer
sudo rm -f /usr/local/bin/wifi-reconnect.sh

sudo systemctl daemon-reload

echo "✅ wifi-reconnect removed."
echo "Log file kept at /var/log/wifi-reconnect.log — remove manually if needed."
