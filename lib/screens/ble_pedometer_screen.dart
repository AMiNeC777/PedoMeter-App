import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pedo_metreapp/services/ble_pedometer_service.dart';

class BLEPedometerScreen extends StatefulWidget {
  const BLEPedometerScreen({super.key});

  @override
  State<BLEPedometerScreen> createState() => _BLEPedometerScreenState();
}

class _BLEPedometerScreenState extends State<BLEPedometerScreen> {
  // Use singleton instance (factory/instance in service)
  final BLEPedometerService _bleService = BLEPedometerService();
  int _stepCount = 0;
  List<ScanResult> _scanResults = [];
  String _statusMessage = 'Ready to scan';

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();

    // Keep local view in sync with global step count
    _stepCount = _bleService.currentStepCount;
    _bleService.stepCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _stepCount = count;
        });
      }
    });
  }

  @override
  void dispose() {
    // Do NOT dispose the BLE service here to preserve connection when leaving screen.
    super.dispose();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final isEnabled = await BLEPedometerService.isBluetoothEnabled();
      if (!isEnabled) {
        _showBluetoothDisabledDialog();
      }
    } catch (e) {
      _updateStatus('Error checking Bluetooth: $e');
    }
  }

  void _showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Disabled'),
        content: const Text('Please enable Bluetooth to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await BLEPedometerService.requestBluetoothPermissions();
              Navigator.pop(context);
              _checkBluetoothStatus();
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScanning() async {
    try {
      setState(() {
        _scanResults = [];
        _statusMessage = 'Scanning for devices...';
      });

      await _bleService.startScanning();

      // Listen to scan results
      _bleService.getScanResults().listen((results) {
        setState(() {
          _scanResults = results;
        });
      });

      // Stop scanning after 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      await _bleService.stopScanning();
      setState(() {
        _statusMessage = 'Scan complete. Found ${_scanResults.length} device(s)';
      });
    } catch (e) {
      _updateStatus('Error scanning: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _updateStatus('Connecting to ${device.name}...');

      await _bleService.connectToDevice(device);

      setState(() {
        _statusMessage = 'Connected to ${device.name}';
      });

      // Listen to step count updates
      _bleService.stepCountStream.listen((stepCount) {
        setState(() {
          _stepCount = stepCount;
        });
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(device.name);
      }
    } catch (e) {
      _updateStatus('Error connecting: $e');
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      _updateStatus('Disconnecting...');
      await _bleService.disconnect();
      setState(() {
        _stepCount = 0;
        _statusMessage = 'Disconnected';
      });
    } catch (e) {
      _updateStatus('Error disconnecting: $e');
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  void _showSuccessDialog(String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connected!'),
        content: Text('Successfully connected to $deviceName.\nWaiting for step updates...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'BLE Pedometer',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 24),

            // Step Counter Display
            if (_bleService.isConnected)
              _buildStepCounterDisplay()
            else
              _buildConnectionPrompt(),
            const SizedBox(height: 24),

            // Control Buttons
            _buildControlButtons(),
            const SizedBox(height: 24),

            // Scan Results
            if (_scanResults.isNotEmpty) _buildDevicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _bleService.isConnected
                ? const Color(0xFF4CAF50)
                : const Color(0xFF2196F3),
            _bleService.isConnected
                ? const Color(0xFF45a049)
                : const Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _bleService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bleService.isConnected ? 'Connected' : 'Disconnected',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _statusMessage,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_bleService.connectedDevice != null) ...[
            const SizedBox(height: 12),
            Text(
              'Device: ${_bleService.connectedDevice!.name.isEmpty ? 'Unknown' : _bleService.connectedDevice!.name}',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCounterDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5CACEB), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Steps Recorded',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _stepCount.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'steps',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPrompt() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bluetooth_disabled,
            color: Colors.grey[600],
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Not Connected',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan for devices and connect to start tracking steps',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: !_bleService.isScanning ? _startScanning : null,
            icon: const Icon(Icons.search),
            label: Text(
              _bleService.isScanning ? 'Scanning...' : 'Scan for Devices',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              disabledBackgroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_bleService.isConnected) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _disconnectDevice,
              icon: const Icon(Icons.bluetooth_disabled),
              label: Text(
                'Disconnect',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDevicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Devices',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _scanResults.length,
          itemBuilder: (context, index) {
            final result = _scanResults[index];
            final device = result.device;
            final isCurrentDevice = _bleService.connectedDevice?.id == device.id;

            return GestureDetector(
              onTap: isCurrentDevice ? null : () => _connectToDevice(device),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isCurrentDevice
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : Colors.grey[900],
                  border: Border.all(
                    color: isCurrentDevice
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[700]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bluetooth_audio,
                      color: isCurrentDevice
                          ? const Color(0xFF4CAF50)
                          : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name.isEmpty ? 'Unknown Device' : device.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            device.id.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'RSSI: ${result.rssi} dBm',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentDevice)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Connected',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
