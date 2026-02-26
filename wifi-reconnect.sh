#!/bin/bash

LOGFILE="/var/log/wifi-reconnect.log"
MAX_FAILURES=3
FAIL_COUNT_FILE="/tmp/wifi_fail_count"

log() {
    echo "$(date -Is) $1" >> "$LOGFILE"
}

SSID=$(/sbin/iwgetid --raw)

if [ -n "$SSID" ]; then
    # Connected — reset failure counter
    echo 0 > "$FAIL_COUNT_FILE"
    exit 0
fi

# Not connected — increment failure count
FAILS=$(cat "$FAIL_COUNT_FILE" 2>/dev/null || echo 0)
FAILS=$((FAILS + 1))
echo "$FAILS" > "$FAIL_COUNT_FILE"

log "WiFi down (attempt $FAILS/$MAX_FAILURES), trying to reconnect..."

/sbin/ip link set wlan0 down
sleep 10
/sbin/ip link set wlan0 up
sleep 20

# Check if reconnect worked
SSID=$(/sbin/iwgetid --raw)
if [ -n "$SSID" ]; then
    log "Reconnected successfully to $SSID"
    echo 0 > "$FAIL_COUNT_FILE"
    exit 0
fi

log "Reconnect failed."

if [ "$FAILS" -ge "$MAX_FAILURES" ]; then
    log "Max failures reached. Rebooting..."
    echo 0 > "$FAIL_COUNT_FILE"
    /sbin/shutdown -r now
fi
