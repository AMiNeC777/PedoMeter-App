import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class BLEDebugScreen extends StatefulWidget {
  const BLEDebugScreen({super.key});

  @override
  State<BLEDebugScreen> createState() => _BLEDebugScreenState();
}

class _BLEDebugScreenState extends State<BLEDebugScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    final state = await FlutterBluePlus.adapterState.first;
    _addLog('Bluetooth State: $state');
    
    if (state != BluetoothAdapterState.on) {
      _addLog('Bluetooth is OFF - Attempting to turn on...');
      try {
        await FlutterBluePlus.turnOn();
        _addLog('Bluetooth turned ON');
      } catch (e) {
        _addLog('Failed to turn on Bluetooth: $e');
      }
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    
    _scanResults.clear();
    _logs.clear();
    _addLog('Starting BLE scan...');
    
    setState(() => _isScanning = true);

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        
        for (var result in results) {
          _addLog(
            'Device: ${result.device.name.isEmpty ? "Unknown" : result.device.name}\n'
            'MAC: ${result.device.remoteId}\n'
            'RSSI: ${result.rssi}',
          );
        }
        
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      _addLog('Scan error: $e');
    }

    setState(() => _isScanning = false);
  }

  Future<void> _stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _addLog('Scan stopped');
      setState(() => _isScanning = false);
    } catch (e) {
      _addLog('Stop scan error: $e');
    }
  }

  Future<void> _connectAndInspect(BluetoothDevice device) async {
    _addLog('Connecting to ${device.name}...');
    
    try {
      await device.connect(license: License.free);
      _addLog('Connected! Discovering services...');

      final services = await device.discoverServices();
      
      for (var service in services) {
        _addLog('\n=== SERVICE ===');
        _addLog('UUID: ${service.uuid}');
        _addLog('Characteristics:');
        
        for (var char in service.characteristics) {
          _addLog('  - UUID: ${char.uuid}');
          _addLog('    Properties: ${char.properties}');
          _addLog('    Read: ${char.properties.read}');
          _addLog('    Write: ${char.properties.write}');
          _addLog('    Notify: ${char.properties.notify}');
          _addLog('    Indicate: ${char.properties.indicate}');
        }
      }

      await device.disconnect();
      _addLog('Disconnected');
    } catch (e) {
      _addLog('Error: $e');
    }

    setState(() {});
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add('${DateTime.now().toString().split('.')[0]} - $message');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Debug Scanner', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: const Icon(Icons.bluetooth_searching),
                  label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScan : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          const Divider(),
          // Scan results
          Expanded(
            child: _scanResults.isEmpty
                ? Center(
                    child: Text(
                      'No devices found\nTap "Start Scan" to begin',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(result.device.name.isEmpty ? 'Unknown Device' : result.device.name),
                          subtitle: Text(result.device.remoteId.toString()),
                          trailing: Text('${result.rssi} dBm'),
                          onTap: () => _connectAndInspect(result.device),
                        ),
                      );
                    },
                  ),
          ),
          // Divider
          const Divider(),
          // Logs
          Expanded(
            child: Container(
              color: Colors.black26,
              child: ListView.builder(
                reverse: true,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _logs[_logs.length - 1 - index],
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: Colors.greenAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}