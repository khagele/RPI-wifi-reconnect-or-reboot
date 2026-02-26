# wifi-reconnect

A lightweight WiFi watchdog for Raspberry Pi that automatically reconnects when the WiFi drops, and reboots as a last resort if reconnection fails repeatedly. Runs as a **systemd timer** (no cron required).

## How it works

Every 60 seconds, a systemd timer fires the watchdog script. The script checks whether the Pi is connected to a WiFi network:

- **Connected** — nothing to do, failure counter resets.
- **Disconnected** — brings `wlan0` down and back up, then waits to see if it reconnects.
  - If it reconnects, logs success and resets the counter.
  - If it fails, increments the failure counter and logs the attempt.
  - After **3 consecutive failures** (~3 minutes), the Pi reboots automatically.

All events (disconnects, reconnect attempts, reboots) are logged to `/var/log/wifi-reconnect.log`.

## Requirements

- Raspberry Pi running Raspberry Pi OS (Bullseye or Bookworm recommended)
- `systemd` (included by default)
- `/sbin/iwgetid` and `/sbin/ip` (included by default)

## Installation

```bash
git clone https://github.com/khagele/wifi-reconnect.git
cd wifi-reconnect
chmod +x install.sh
./install.sh
```

That's it. The watchdog starts immediately and will auto-start on every boot.

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Monitoring

**Live systemd logs:**
```bash
journalctl -u wifi-reconnect.service -f
```

**WiFi event log (only shows disconnect/reconnect events):**
```bash
tail -f /var/log/wifi-reconnect.log
```

**Check timer status:**
```bash
systemctl status wifi-reconnect.timer
```

**Example log output when WiFi drops and recovers:**
```
2025-03-01T14:22:01+00:00 WiFi down (attempt 1/3), trying to reconnect...
2025-03-01T14:22:32+00:00 Reconnected successfully to MyNetwork
```

**Example log output when reboot is triggered:**
```
2025-03-01T14:22:01+00:00 WiFi down (attempt 1/3), trying to reconnect...
2025-03-01T14:22:32+00:00 Reconnect failed.
2025-03-01T14:23:33+00:00 WiFi down (attempt 2/3), trying to reconnect...
2025-03-01T14:24:04+00:00 Reconnect failed.
2025-03-01T14:25:05+00:00 WiFi down (attempt 3/3), trying to reconnect...
2025-03-01T14:25:36+00:00 Reconnect failed.
2025-03-01T14:25:36+00:00 Max failures reached. Rebooting...
```

## Configuration

You can adjust two variables at the top of `wifi-reconnect.sh`:

| Variable | Default | Description |
|---|---|---|
| `MAX_FAILURES` | `3` | Number of failed reconnect attempts before rebooting |
| `LOGFILE` | `/var/log/wifi-reconnect.log` | Path to the event log |

To change how often the check runs, edit the `OnUnitActiveSec` value in `wifi-reconnect.timer` (default: `60` seconds), then run `sudo systemctl daemon-reload`.

## Tip for Bookworm / NetworkManager users

If you're on Raspberry Pi OS Bookworm, NetworkManager may be limiting its own reconnect retries. Run this to make it retry forever:

```bash
nmcli connection modify preconfigured connection.autoconnect-retries 0
```

This works alongside the watchdog script for extra reliability.

## File structure

```
wifi-reconnect/
├── README.md
├── install.sh              # Installs and enables the service
├── uninstall.sh            # Removes everything
├── wifi-reconnect.sh       # The watchdog script
├── wifi-reconnect.service  # systemd service unit
└── wifi-reconnect.timer    # systemd timer unit (runs every 60s)
```

## Credits

Inspired by [carry0987's gist](https://gist.github.com/carry0987/372b9fefdd8041d0374f4e08fbf052b1), extended with reboot fallback, failure counting, and systemd timer support.

## License

MIT
