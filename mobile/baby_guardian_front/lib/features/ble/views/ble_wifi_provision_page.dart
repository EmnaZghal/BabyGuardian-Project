import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble_consts.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';
import 'package:baby_guardian_front/features/babies_page_selection/services/baby_api.dart';

class BleWifiProvisionPage extends StatefulWidget {
  final String babyId;
  final String? babyName;

  const BleWifiProvisionPage({
    super.key,
    required this.babyId,
    this.babyName,
  });

  @override
  State<BleWifiProvisionPage> createState() => _BleWifiProvisionPageState();
}

class _BleWifiProvisionPageState extends State<BleWifiProvisionPage> {
  final _ssidCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _auth = AuthService();

  StreamSubscription<List<ScanResult>>? _scanSub1;
  StreamSubscription<List<ScanResult>>? _scanSub2;
  StreamSubscription<List<int>>? _statusUiSub;

  final List<ScanResult> _results = [];
  BluetoothDevice? _device;

  BluetoothCharacteristic? _infoChar;
  BluetoothCharacteristic? _configChar;
  BluetoothCharacteristic? _statusChar;

  String? _deviceId;
  int _status = BleConsts.stIdle;

  bool _scanning = false;
  bool _connecting = false;
  bool _sending = false;

  @override
  void dispose() {
    _ssidCtrl.dispose();
    _passCtrl.dispose();
    _scanSub1?.cancel();
    _scanSub2?.cancel();
    _statusUiSub?.cancel();
    _disconnectQuiet();
    super.dispose();
  }

  Future<void> _disconnectQuiet() async {
    try {
      await _device?.disconnect();
    } catch (_) {}
  }

  // ✅ SOLUTION 1: Safe back (no crash if nothing to pop)
  void _safeBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      // fallback (choose the page you want)
      router.go('/select-baby'); // or '/home'
    }
  }

  String _statusText(int st) {
    switch (st) {
      case BleConsts.stIdle:
        return "Idle";
      case BleConsts.stReceived:
        return "Credentials received";
      case BleConsts.stWifiConnecting:
        return "Connecting Wi-Fi…";
      case BleConsts.stWifiOk:
        return "Wi-Fi connected ✅";
      case BleConsts.stWifiFail:
        return "Wi-Fi failed ❌";
      default:
        return "Unknown ($st)";
    }
  }

  Future<void> _ensureBlePermissions() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Android requires location permission to scan for Bluetooth devices.\n\n'
              'This app does NOT track your location. The permission is only used '
              'to discover nearby BLE devices.\n\n'
              'Please grant location permission to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      throw Exception("Location permission required for BLE scan");
    }

    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();

    if (!scan.isGranted || !connect.isGranted) {
      throw Exception("Bluetooth permissions not granted");
    }
  }

  String _bestName(ScanResult r) {
    final advName = r.advertisementData.advName;
    if (advName.isNotEmpty) return advName;
    final platformName = r.device.platformName;
    if (platformName.isNotEmpty) return platformName;
    return "(no name)";
  }

  bool _matchesBabyGuardian(ScanResult r) {
    final name = _bestName(r);

    final hasPrefix = name.startsWith(BleConsts.namePrefix);

    final hasService = r.advertisementData.serviceUuids.any(
      (u) => u.str.toLowerCase() == BleConsts.svcUuid.toLowerCase(),
    );

    return hasPrefix || hasService;
  }

  void _addIfMatch(ScanResult r) {
    final name = _bestName(r);
    final uuids = r.advertisementData.serviceUuids.map((u) => u.str).join(', ');

    // ignore: avoid_print
    print(
      "📡 SCAN: name='$name' id=${r.device.remoteId.str} rssi=${r.rssi} uuids=[$uuids]",
    );

    if (!_matchesBabyGuardian(r)) return;

    final exists = _results.any((e) => e.device.remoteId == r.device.remoteId);
    if (!exists) {
      if (mounted) setState(() => _results.add(r));
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _results.clear();
      _scanning = true;
      _device = null;
      _deviceId = null;
      _status = BleConsts.stIdle;
    });

    try {
      await FlutterBluePlus.turnOn();
      await _ensureBlePermissions();

      try {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: 400));
      } catch (_) {}

      _scanSub1?.cancel();
      _scanSub2?.cancel();

      _scanSub1 = FlutterBluePlus.scanResults.listen((list) {
        for (final r in list) {
          _addIfMatch(r);
        }
      });

      _scanSub2 = FlutterBluePlus.onScanResults.listen((list) {
        for (final r in list) {
          _addIfMatch(r);
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: true,
      );

      await Future.delayed(const Duration(seconds: 30));
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      if (_results.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ No BabyGuardian devices found.\n\n'
              'Make sure:\n'
              '• ESP32 is powered on\n'
              '• ESP32 is within 5 meters\n'
              '• No other device is connected to it',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scan error: $e")),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _connect(ScanResult r) async {
    setState(() {
      _connecting = true;
      _device = r.device;
      _deviceId = null;
      _status = BleConsts.stIdle;
    });

    try {
      await _ensureBlePermissions();

      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}

      try {
        await r.device.connect(
          timeout: const Duration(seconds: 15),
          autoConnect: false,
        );
      } catch (_) {}

      final services = await r.device.discoverServices();

      BluetoothCharacteristic? info;
      BluetoothCharacteristic? cfg;
      BluetoothCharacteristic? st;

      for (final s in services) {
        if (s.uuid.toString().toLowerCase() == BleConsts.svcUuid.toLowerCase()) {
          for (final c in s.characteristics) {
            final u = c.uuid.toString().toLowerCase();
            if (u == BleConsts.infoUuid.toLowerCase()) info = c;
            if (u == BleConsts.configUuid.toLowerCase()) cfg = c;
            if (u == BleConsts.statusUuid.toLowerCase()) st = c;
          }
        }
      }

      if (info == null || cfg == null || st == null) {
        throw Exception("BLE chars not found. Check UUIDs.");
      }

      _infoChar = info;
      _configChar = cfg;
      _statusChar = st;

      final bytes = await _infoChar!.read();
      _deviceId = utf8.decode(bytes).trim();

      await _statusChar!.setNotifyValue(true);
      _statusUiSub?.cancel();
      _statusUiSub = _statusChar!.onValueReceived.listen((val) {
        if (val.isEmpty) return;
        if (!mounted) return;
        setState(() => _status = val.first);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Connected to $_deviceId')),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _sendWifiThenBind() async {
    FocusScope.of(context).unfocus();

    if (_device == null ||
        _configChar == null ||
        _statusChar == null ||
        _deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please connect to a BLE device first')),
      );
      return;
    }

    final ssid = _ssidCtrl.text.trim();
    final pass = _passCtrl.text;

    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ SSID is required')),
      );
      return;
    }
    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Password is required')),
      );
      return;
    }

    setState(() {
      _sending = true;
      _status = BleConsts.stIdle;
    });

    StreamSubscription<List<int>>? waitSub;

    try {
      final completer = Completer<int>();

      waitSub = _statusChar!.onValueReceived.listen((val) {
        if (val.isEmpty) return;
        final st = val.first;

        if (mounted) setState(() => _status = st);

        if (st == BleConsts.stWifiOk || st == BleConsts.stWifiFail) {
          if (!completer.isCompleted) completer.complete(st);
        }
      });

      // 1) Send ssid|pass to ESP32
      await _configChar!.write(
        utf8.encode('$ssid|$pass'),
        withoutResponse: false,
      );

      // 2) Wait Wi-Fi OK/FAIL
      final finalStatus = await completer.future.timeout(
        const Duration(seconds: 50),
        onTimeout: () => BleConsts.stWifiFail,
      );

      if (finalStatus != BleConsts.stWifiOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Wi-Fi connection failed: ${_statusText(finalStatus)}',
            ),
          ),
        );
        return;
      }

      // 3) Bind device to baby
      await BabyApi.bindDevice(
        auth: _auth,
        babyId: widget.babyId,
        deviceId: _deviceId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Device linked successfully!\n$_deviceId')),
      );

      // 4) Go to HOME
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      await waitSub?.cancel();
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectedName = _device?.platformName;
    final hasConnectedName = connectedName != null && connectedName.isNotEmpty;

    final babyLabel = widget.babyName?.isNotEmpty == true
        ? 'Baby: ${widget.babyName}'
        : 'Baby selected';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          // ✅ FIXED: safe back (no "There is nothing to pop")
          onPressed: _safeBack,
        ),
        title: const Text(
          'Connect Wi-Fi via BLE',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final listMaxHeight =
                  (constraints.maxHeight * 0.40).clamp(180.0, 320.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Baby info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.child_care,
                                  color: Color(0xFF16A34A)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  babyLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Scan button
                        ElevatedButton.icon(
                          onPressed: _scanning ? null : _startScan,
                          icon: _scanning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.bluetooth_searching),
                          label: Text(_scanning ? 'Scanning...' : 'Scan BLE Devices'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Device list (limited height)
                        Container(
                          height: listMaxHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: _results.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bluetooth_disabled,
                                          size: 56, color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No BabyGuardian devices found',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Press "Scan" to search',
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _results.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final r = _results[i];
                                    final name = _bestName(r);
                                    final isThisDevice =
                                        _device?.remoteId == r.device.remoteId;
                                    final isConnecting =
                                        _connecting && isThisDevice;

                                    return ListTile(
                                      title: Text(
                                        name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ),
                                      subtitle: Text(
                                        '${r.device.remoteId.str}\nRSSI: ${r.rssi} dBm',
                                      ),
                                      trailing: isConnecting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : Icon(isThisDevice
                                              ? Icons.check_circle
                                              : Icons.chevron_right),
                                      onTap:
                                          isConnecting ? null : () => _connect(r),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Status box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Connected: ${hasConnectedName ? connectedName : '-'}"),
                              const SizedBox(height: 4),
                              Text(
                                "Device ID: ${_deviceId ?? '-'}",
                                style:
                                    const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text("Status: ${_statusText(_status)}"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _ssidCtrl,
                          decoration: InputDecoration(
                            labelText: 'Wi-Fi SSID',
                            prefixIcon: const Icon(Icons.wifi),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Wi-Fi Password',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: _sending ? null : _sendWifiThenBind,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC4899),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Send Wi-Fi + Bind Device',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
