# BLE Pedometer Implementation Guide

## Overview
This guide documents the Bluetooth Low Energy (BLE) Pedometer integration for the PedoMetre app. The implementation allows users to scan for, connect to, and receive step count data from a Pico Pedometer device.

## Architecture

### Components

#### 1. **BLEPedometerService** (`lib/services/ble_pedometer_service.dart`)
The core service that handles all BLE operations:

- **Device Discovery**: Scans for BLE devices with configurable timeout
- **Connection Management**: Connects to discovered devices
- **Service Discovery**: Discovers services on connected devices
- **Characteristic Management**: Finds and subscribes to the step count characteristic
- **Data Processing**: Decodes received step count data from bytes to integers
- **Stream Management**: Provides streams for step count, connection status, and scan status

**Key Methods**:
- `startScanning()` - Begin BLE device scan
- `stopScanning()` - Stop scanning
- `connectToDevice(BluetoothDevice)` - Connect to a specific device
- `discoverServices()` - Discover available services
- `disconnect()` - Disconnect from device
- `dispose()` - Clean up resources

**Streams**:
- `stepCountStream` - Emits integer step counts as they arrive
- `connectionStatusStream` - Emits connection state changes (true/false)
- `scanStatusStream` - Emits scan state changes (true/false)

#### 2. **BLEPedometerScreen** (`lib/screens/ble_pedometer_screen.dart`)
The UI component for managing BLE connections:

**Features**:
- Real-time Bluetooth adapter status checking
- Device scanning with results display
- Connection management with visual feedback
- Live step count display
- Device information (name, MAC address, RSSI signal strength)
- Status messages for user feedback

**Key UI Elements**:
- Status Card: Shows connection state and current device
- Step Counter Display: Large number showing current steps
- Control Buttons: Scan and Disconnect buttons
- Devices List: Shows found devices with signal strength

## Implementation Details

### Device Discovery Flow

```
1. User taps "Scan for Devices" button
   ↓
2. BLEPedometerService.startScanning() starts scan
   ↓
3. FlutterBluePlus.startScan() begins device scan
   ↓
4. Scan results stream updates with found devices
   ↓
5. User selects a device to connect
   ↓
6. BLEPedometerService.connectToDevice() is called
```

### Connection Flow

```
1. stopScanning() - Stop the device scan
   ↓
2. device.connect() - Connect to selected device
   ↓
3. discoverServices() - Discover available services
   ↓
4. _setupStepCountCharacteristic() - Find and subscribe to characteristic
   ↓
5. setNotifyValue(true) - Enable notifications
   ↓
6. Listen to onValueReceived stream for updates
```

### Data Processing Flow

```
Raw BLE Data (List<int>)
   ↓
ByteData.view() - Convert to ByteData
   ↓
getUint32() - Decode as 32-bit unsigned integer (little-endian)
   ↓
_stepCountController.add() - Emit to stepCountStream
   ↓
UI Updates with new step count
```

## UUID Configuration

The service uses the following UUIDs (currently set as examples):

```dart
// Service UUID
static const String pedometerServiceUuid = '180A';

// Characteristic UUID for step count
static const String stepCountCharUuid = '2A3F';

// Device name to identify
static const String deviceName = 'Pico Pedometer';
```

**To customize these UUIDs**:
1. Open `lib/services/ble_pedometer_service.dart`
2. Update the UUID constants with your Pico Pedometer's UUIDs
3. Rebuild and redeploy the app

## Dependencies

The implementation uses `flutter_blue_plus` v2.0.2:

```yaml
flutter_blue_plus: ^2.0.2
```

This is already included in `pubspec.yaml`.

## Bluetooth Permissions

### Android (`android/app/build.gradle`)
Add to `AndroidManifest.xml`:
```xml
<!-- Bluetooth permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
Add:
```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to connect to your Pico Pedometer device</string>
<key>NSBluetoothCentralUsageDescription</key>
<string>This app needs Bluetooth access to scan for and connect to your Pico Pedometer device</string>
```

## Usage

### Basic Flow

1. **Navigate to BLE Screen**
   - Tap the Bluetooth icon in the home screen app bar

2. **Scan for Devices**
   - Tap "Scan for Devices" button
   - Wait for devices to appear (max 10 seconds)

3. **Connect to Device**
   - Select your Pico Pedometer from the list
   - App will automatically:
     - Stop scanning
     - Connect to device
     - Discover services
     - Subscribe to step count updates

4. **View Step Count**
   - Step count updates appear in real-time
   - Connection status shows at the top
   - Device info displays in the status card

5. **Disconnect**
   - Tap "Disconnect" button
   - Connection is closed and notifications disabled

### Error Handling

The service includes error handling for:
- Bluetooth not enabled
- Device not found
- Connection failures
- Service discovery failures
- Characteristic not found
- Data decoding errors

All errors are displayed as status messages to the user.

## Advanced Features

### Monitoring Connection Status

```dart
_bleService.connectionStatusStream.listen((isConnected) {
  // Handle connection changes
  // isConnected = true when connected
  // isConnected = false when disconnected
});
```

### Getting Real-time Step Updates

```dart
_bleService.stepCountStream.listen((stepCount) {
  print('Current steps: $stepCount');
  // Update UI or perform other actions
});
```

### Checking Scan Status

```dart
_bleService.scanStatusStream.listen((isScanning) {
  // Update UI to show scan progress
});
```

## Troubleshooting

### Device Not Found
- Ensure Pico Pedometer is powered on
- Check device name matches `pedometerServiceUuid` constant
- Verify Bluetooth is enabled on phone
- Check permissions are granted

### Connection Fails
- Ensure device isn't already connected to another app
- Try restarting the device
- Check Bluetooth adapter on phone is working
- Verify iOS Info.plist and Android AndroidManifest.xml have required permissions

### No Step Count Updates
- Verify characteristic UUID is correct
- Check if device sends notifications (vs. read-only data)
- Ensure notification subscription succeeded
- Check data format matches 4-byte uint32 little-endian assumption

### Bluetooth Permission Issues

**Android**:
- Grant Bluetooth scan and connect permissions
- Grant location permission (required for scanning on Android 6+)

**iOS**:
- Grant Bluetooth permission when prompted
- Check privacy settings in Settings > [App Name]

## Customization

### Change Scan Timeout
```dart
await _bleService.startScanning(timeout: Duration(seconds: 15));
```

### Custom Data Decoding
If the step count format is different (e.g., big-endian, different size):

In `_processStepData()`:
```dart
// For big-endian 32-bit integer
final stepCount = byteData.getUint32(0, Endian.big);

// For 16-bit integer
final stepCount = byteData.getUint16(0, Endian.little);

// For single byte
final stepCount = data[0];
```

## Performance Considerations

- Scanning is limited to 10 seconds by default to save battery
- Notifications are disabled on disconnect to prevent battery drain
- Streams use `.broadcast()` to support multiple listeners
- Resources are properly disposed in `dispose()` method

## Testing

### Mock Testing
You can create a mock version of `BLEPedometerService` for testing without a real device:

```dart
class MockBLEPedometerService extends BLEPedometerService {
  @override
  Future<void> startScanning() async {
    // Return mock results
  }
}
```

### Manual Testing Checklist
- [ ] Scan finds devices
- [ ] Connection succeeds
- [ ] Step count updates appear
- [ ] Disconnect works properly
- [ ] Error messages display correctly
- [ ] Bluetooth permission requests work

## Integration with Home Screen

The BLE Pedometer Screen is accessible from the Home Screen via a Bluetooth icon button in the app bar:

```dart
IconButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BLEPedometerScreen(),
      ),
    );
  },
  icon: const Icon(Icons.bluetooth),
),
```

## Future Enhancements

1. **Battery Status**: Monitor Pico Pedometer battery level
2. **Historical Data**: Fetch past step count history from device
3. **Auto-reconnect**: Automatically reconnect to last used device
4. **Multiple Devices**: Support connecting to multiple devices
5. **Settings**: Allow users to configure UUIDs in app settings
6. **Data Sync**: Sync step data with cloud storage
7. **Notifications**: Alert user of step count milestones
8. **Debug Mode**: Add detailed BLE logging for troubleshooting

## Resources

- [Flutter Blue Plus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [Bluetooth Core Specification](https://www.bluetooth.com/specifications/specs/)
- [Flutter Plugins Guide](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review error logs in Flutter console
3. Verify all permissions are granted
4. Test with a different device if possible
5. Check device manufacturer documentation
