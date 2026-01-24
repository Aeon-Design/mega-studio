# IoT Connectivity Grimoire 🔌

> **Domain:** Internet of Things (BLE, MQTT, Hardware Integration)
> **Goal:** Zero-friction device connectivity and reliability.

## 📡 Bluetooth Low Energy (BLE)
- **Scanning:** Implement scanning timeouts to save battery.
- **MTU Size:** Negotiate MTU size early for high-throughput data.
- **Reconnection:** Use exponential backoff for dropped connections.

## ☁️ MQTT Protocol
- **QoS Levels:** Use QoS 1 for critical commands, QoS 0 for telemetry.
- **Retained Messages:** Use for last-known device configuration.
- **Last Will:** Implement to detect device disconnection instantly.

## 🛡️ Security & Privacy
- **Bonding:** Use AES encryption and bonding where hardware supports it.
- **Authentication:** Challenge-response handshake for unauthorized app connections.

## 🔋 Power Management
- **Sleep Cycles:** Respect hardware sleep modes in the software poll frequency.
- **Background Tasks:** Use `WorkManager` for periodic syncs without waking the screen.
