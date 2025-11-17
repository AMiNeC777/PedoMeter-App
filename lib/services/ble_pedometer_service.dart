import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEPedometerService {
  // UUIDs for Pico Pedometer
  static const String pedometerServiceUuid = '180A'; // Example service UUID
  static const String stepCountCharUuid = '2A3F'; // Example characteristic UUID
  static const String deviceName = 'Pico Pedometer';

  late BluetoothDevice _connectedDevice;
  late BluetoothCharacteristic _stepCountCharacteristic;
  
  final _stepCountController = StreamController<int>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _scanStatusController = StreamController<bool>.broadcast();
  
  Stream<int> get stepCountStream => _stepCountController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<bool> get scanStatusStream => _scanStatusController.stream;
  
  bool _isScanning = false;
  bool _isConnected = false;
  
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _isConnected ? _connectedDevice : null;

  /// Start scanning for BLE devices
  Future<void> startScanning({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      _isScanning = true;
      _scanStatusController.add(true);
      
      await FlutterBluePlus.startScan(
        timeout: timeout,
      );
    } catch (e) {
      _isScanning = false;
      _scanStatusController.add(false);
      rethrow;
    }
  }

  /// Stop scanning for devices
  Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      _scanStatusController.add(false);
    } catch (e) {
      rethrow;
    }
  }

  /// Get scan results as a stream
  Stream<List<ScanResult>> getScanResults() {
    return FlutterBluePlus.scanResults;
  }

  /// Connect to a discovered device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await stopScanning();
      
      // Connect to device - for flutter_blue_plus 2.x, license is required
      // Create an empty/free license for open-source use
      await device.connect(
        license: License.free,
      );
      
      _connectedDevice = device;
      _isConnected = true;
      _connectionStatusController.add(true);
      
      // Discover services
      await discoverServices();
      
      // Find and setup the step count characteristic
      await _setupStepCountCharacteristic();
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      rethrow;
    }
  }

  /// Discover services on the connected device
  Future<void> discoverServices() async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }

    try {
      await _connectedDevice.discoverServices();
    } catch (e) {
      rethrow;
    }
  }

  /// Setup and subscribe to step count characteristic
  Future<void> _setupStepCountCharacteristic() async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }

    try {
      final services = await _connectedDevice.discoverServices();
      
      BluetoothCharacteristic? stepCountChar;
      
      // Search for the characteristic
      for (var service in services) {
        // Try to match by service UUID
        if (service.uuid.toString().toLowerCase().contains(pedometerServiceUuid.toLowerCase())) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().contains(stepCountCharUuid.toLowerCase())) {
              stepCountChar = characteristic;
              break;
            }
          }
        }
      }
      
      // If not found, search all services for the characteristic
      if (stepCountChar == null) {
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase().contains(stepCountCharUuid.toLowerCase())) {
              stepCountChar = characteristic;
              break;
            }
          }
        }
      }
      
      if (stepCountChar == null) {
        throw Exception('Step count characteristic not found');
      }
      
      _stepCountCharacteristic = stepCountChar;
      
      // Check if the characteristic supports notifications
      if (_stepCountCharacteristic.properties.notify) {
        await _stepCountCharacteristic.setNotifyValue(true);
        
        // Listen to value changes
        _stepCountCharacteristic.onValueReceived.listen((value) {
          _processStepData(value);
        });
      } else if (_stepCountCharacteristic.properties.read) {
        // If notifications aren't supported, try reading
        final value = await _stepCountCharacteristic.read();
        _processStepData(value);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Process received step count data
  void _processStepData(List<int> data) {
    try {
      if (data.isEmpty) {
        return;
      }
      
      // Decode the data based on the format
      // Assuming 4-byte integer (uint32) in little-endian format
      final byteData = ByteData.view(Uint8List.fromList(data.sublist(0, 4)).buffer);
      final stepCount = byteData.getUint32(0, Endian.little);
      
      _stepCountController.add(stepCount);
    } catch (e) {
      print('Error processing step data: $e');
    }
  }

  /// Disconnect from device
  Future<void> disconnect() async {
    try {
      if (_stepCountCharacteristic.properties.notify) {
        await _stepCountCharacteristic.setNotifyValue(false);
      }
      
      await _connectedDevice.disconnect();
      _isConnected = false;
      _connectionStatusController.add(false);
    } catch (e) {
      rethrow;
    }
  }

  /// Cleanup resources
  void dispose() {
    _stepCountController.close();
    _connectionStatusController.close();
    _scanStatusController.close();
  }

  /// Get Bluetooth adapter status
  static Stream<BluetoothAdapterState> getBluetoothState() {
    return FlutterBluePlus.adapterState;
  }

  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// Request Bluetooth permissions and enable if needed
  static Future<void> requestBluetoothPermissions() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      rethrow;
    }
  }
}
