# Quick Start: BLE Pedometer Integration

## 🚀 Get Started in 5 Minutes

### Step 1: Configure Your Device UUIDs (2 min)

Edit `lib/services/ble_pedometer_service.dart` and update these lines with your Pico Pedometer's actual UUIDs:

```dart
class BLEPedometerService {
  // UPDATE THESE VALUES FOR YOUR DEVICE
  static const String pedometerServiceUuid = '180A';        // ← Your service UUID
  static const String stepCountCharUuid = '2A3F';           // ← Your characteristic UUID
  static const String deviceName = 'Pico Pedometer';        // ← Your device name
  
  // ... rest of the code
}
```

**How to find your device's UUIDs:**
1. Use a BLE scanner app (like nRF Connect) on your phone
2. Scan and find "Pico Pedometer"
3. Note the Service UUID and Characteristic UUID
4. Replace the values above

---

### Step 2: Set Permissions

#### Android
Edit `android/app/src/main/AndroidManifest.xml` and add inside `<manifest>` tag:

```xml
<!-- Bluetooth Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS
Edit `ios/Runner/Info.plist` and add inside the `<dict>` tag:

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to your Pico Pedometer</string>
<key>NSBluetoothCentralUsageDescription</key>
<string>This app needs Bluetooth to scan for your Pico Pedometer</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for Bluetooth scanning</string>
```

---

### Step 3: Build & Run

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run the app
flutter run
```

---

### Step 4: Test

1. **Launch the app** and go to Home Screen
2. **Tap the Bluetooth icon** (blue icon in top-right of app bar)
3. **Tap "Scan for Devices"** - Wait up to 10 seconds
4. **Select your Pico Pedometer** from the list
5. **Watch the step count update** in real-time! 🎉

---

## 📱 Feature Overview

### Main Screen
```
┌─────────────────────────────────┐
│  Home Screen                    │
├─────────────────────────────────┤
│ [Logo] PedoMetre      [🔔] [📱] │  ← Bluetooth icon
├─────────────────────────────────┤
│ Good work for today!            │
│ Run Your Way to Better Health   │
│                                 │
│ [Daily Stats] [Heart Rate]      │
│ [Distance]    [Calories]        │
└─────────────────────────────────┘
```

### BLE Pedometer Screen
```
┌─────────────────────────────────┐
│ ← BLE Pedometer                 │
├─────────────────────────────────┤
│ ┌───────────────────────────────┐│
│ │ 📱 Connected                  ││
│ │ Connected to Pico Pedometer   ││
│ │ Device: Pico Pedometer        ││
│ └───────────────────────────────┘│
│                                 │
│ ┌───────────────────────────────┐│
│ │     Steps Recorded            ││
│ │          8451                 ││
│ │         steps                 ││
│ └───────────────────────────────┘│
│                                 │
│ [📡 Scan for Devices]           │
│ [❌ Disconnect]                 │
│                                 │
│ Available Devices:              │
│ ┌───────────────────────────────┐│
│ │ 📡 Pico Pedometer  [Connected]││
│ │    MAC: XX:XX:XX:XX:XX:XX     ││
│ │    RSSI: -45 dBm              ││
│ └───────────────────────────────┘│
└─────────────────────────────────┘
```

---

## 🔧 Troubleshooting Quick Fixes

### "Device not found"
- [ ] Is Pico Pedometer powered on?
- [ ] Is Bluetooth enabled on phone?
- [ ] Check device name matches configuration
- [ ] Try restarting both devices

### "Connection fails"
- [ ] Close any other BLE apps
- [ ] Disconnect device from other devices
- [ ] Check permissions are granted
- [ ] Try again after 5 seconds

### "No step updates"
- [ ] Verify characteristic UUID is correct
- [ ] Check device sends notifications
- [ ] Ensure connection shows "Connected" state
- [ ] Restart the app

### "Permission denied"
- [ ] **Android**: Settings > Apps > [App Name] > Permissions > Grant all Bluetooth
- [ ] **iOS**: Settings > [App Name] > Bluetooth > Turn on
- [ ] Uninstall and reinstall app if still denied

---

## 📖 File Structure

```
lib/
├── main.dart                              (unchanged)
├── screens/
│   ├── home_screen.dart                   (+ Bluetooth button)
│   ├── ble_pedometer_screen.dart          ✨ NEW - Main BLE UI
│   ├── stats_screen.dart                  (unchanged)
│   └── welcom_screen.dart                 (unchanged)
├── services/
│   ├── ble_pedometer_service.dart         ✨ NEW - BLE logic
│   ├── step_counter_service.dart          (unchanged)
│   └── stats_service.dart                 (unchanged)
└── widgets/
    └── ...                                (unchanged)

Documentation:
├── BLE_PEDOMETER_GUIDE.md                 ✨ NEW - Full guide
├── IMPLEMENTATION_SUMMARY.md              ✨ NEW - Summary
└── QUICK_START.md                         ✨ NEW - This file
```

---

## 🎯 API Reference

### BLEPedometerService Methods

```dart
// Scanning
Future<void> startScanning({Duration timeout})
Future<void> stopScanning()
Stream<List<ScanResult>> getScanResults()

// Connection
Future<void> connectToDevice(BluetoothDevice device)
Future<void> disconnect()

// Service Discovery
Future<void> discoverServices()

// Streams (for listening)
Stream<int> get stepCountStream              // Step count updates
Stream<bool> get connectionStatusStream      // Connection state
Stream<bool> get scanStatusStream           // Scan state

// Properties (for checking state)
bool get isScanning
bool get isConnected
BluetoothDevice? get connectedDevice

// Static Methods
static Future<bool> isBluetoothEnabled()
static Future<void> requestBluetoothPermissions()
static Stream<BluetoothAdapterState> getBluetoothState()

// Cleanup
void dispose()
```

### Usage Example

```dart
// Create service
final ble = BLEPedometerService();

// Listen to step updates
ble.stepCountStream.listen((steps) {
  print('Steps: $steps');
});

// Start scanning
await ble.startScanning();

// Get scan results
ble.getScanResults().listen((results) {
  for (var result in results) {
    print('Found: ${result.device.name}');
  }
});

// Connect to device
await ble.connectToDevice(device);

// Check if connected
if (ble.isConnected) {
  print('Connected!');
}

// Disconnect
await ble.disconnect();

// Cleanup when done
ble.dispose();
```

---

## ✅ Validation Checklist

Before deploying, verify:

- [ ] UUID values match your Pico Pedometer
- [ ] Android permissions added to AndroidManifest.xml
- [ ] iOS privacy descriptions added to Info.plist
- [ ] App builds without errors (`flutter build`)
- [ ] Bluetooth icon visible in Home Screen
- [ ] BLE screen opens when tapping Bluetooth icon
- [ ] Scanning discovers your device
- [ ] Connection succeeds
- [ ] Step count updates appear
- [ ] Disconnect works properly
- [ ] Error messages display when issues occur

---

## 📞 Need Help?

1. **Check the full guide:** `BLE_PEDOMETER_GUIDE.md`
2. **Check the summary:** `IMPLEMENTATION_SUMMARY.md`
3. **Review error messages** - they indicate what's wrong
4. **Check Flutter console** for detailed error logs
5. **Verify permissions** are properly set
6. **Test with nRF Connect** app to verify device UUIDs

---

## 🎉 Success!

Once you see the step count updating in real-time, you're done! 

The BLE Pedometer is now integrated into your PedoMetre app.

Enjoy tracking your steps! 👟📱✨
