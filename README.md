# 🏃‍♂️ Smart Pedometer — IoT Fitness Tracker

A **portable smart pedometer** based on the **Raspberry Pi Pico W (2022)** and **MMA8452Q 3-axis accelerometer**, designed to count steps, estimate distance & calories, and send live data to a **mobile app** via Wi-Fi/Bluetooth.  
This project combines **embedded IoT**, **sensor data processing**, and **mobile app development** to create a complete fitness tracking solution.

---

## 📱 Project Overview

### 🎯 Goal
Build a **low-cost, portable step counter** (pedometer) that tracks physical activity in real-time and syncs progress with a mobile dashboard.

### ⚙️ Features
- 👣 Real-time step counting using the **MMA8452Q accelerometer**
- 📶 Wireless communication via **Wi-Fi (Pico W)** or **Bluetooth**
- 📊 Live display of steps on the mobile app
- 🔋 Battery powered (using PS3 controller battery)
- 💾 Data logging for achievements & history
- 💤 Power-saving sleep mode
- ⌚ Compact wearable design (strap or watch-style case)

---

## 🧠 System Architecture
 ┌─────────────────────────────┐
 │     Raspberry Pi Pico W     │
 │  + MMA8452Q Accelerometer   │
 │  + TP4056 Charger + Battery │
 └────────────┬────────────────┘
               │ Wi-Fi / BLE
               ▼
     ┌──────────────────────────┐
     │     Mobile Application    │
     │  (Flutter / Android)      │
     │  → Displays Steps         │
     │  → Stores Achievements    │
     └──────────────────────────┘
     
---

## 🧩 Hardware Components

| Component | Description | Approx. Price (USD) |
|------------|--------------|---------------------|
| Raspberry Pi Pico W (2022) | Microcontroller with Wi-Fi | $7–10 |
| GY-45 MMA8452Q | 3-Axis Accelerometer | $3–5 |
| PS3 Battery | 3.7V Li-ion rechargeable | Free–$5 |
| TP4056 Module | Li-ion charger (micro USB) | $1–2 |
| OLED Display (optional) | SSD1306 0.96" I²C | $3–5 |
| Breadboard + Wires | For prototyping | $5–10 |
| 3D Printed Case | Custom design | $2–5 |
| Misc. (switch, resistors, wire) | Small accessories | $2–3 |

🧾 **Total Cost Estimate:** ~$25–40 (≈ 250–400 MAD)

---

## 🧰 Software Stack

| Layer | Technology |
|-------|-------------|
| **Microcontroller** | Raspberry Pi Pico W |
| **Language** | MicroPython / C++ |
| **Sensor** | MMA8452Q (I²C) |
| **Mobile App** | Flutter (Dart) |
| **Database (optional)** | Firebase / SQLite |
| **Communication** | Wi-Fi (HTTP/MQTT) or Bluetooth (BLE) |
| **Visualization** | Flutter charts + dashboard UI |

---

## 🛠️ Setup Guide

### 1️⃣ Hardware Connections (MMA8452Q → Pico W)

| MMA8452Q Pin | Pico Pin |
|---------------|----------|
| VCC | 3.3V |
| GND | GND |
| SDA | GP0 |
| SCL | GP1 |
| INT1 | Optional (for motion interrupt) |

### 2️⃣ Flash Pico with MicroPython
1. Download the **MicroPython UF2** for Pico W from [Raspberry Pi official site](https://micropython.org/download/rp2-pico-w/).  
2. Hold **BOOTSEL** while connecting the Pico to your PC.  
3. Copy the UF2 file to the mounted drive.  
4. The Pico will reboot into MicroPython mode.

### 3️⃣ Install Dependencies
```bash
pip install rshell adafruit-ampy
