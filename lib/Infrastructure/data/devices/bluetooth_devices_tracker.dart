import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:synchronized/synchronized.dart';

enum TrackingState {
  idle,
  tracking,
  stopped,
}

/// A utility class for tracking nearby Bluetooth devices using FlutterBluePlus.
///
/// This tracker listens to Bluetooth scan results and keeps a unique collection of
/// discovered devices. It supports:
///
/// - Real-time tracking of scanned Bluetooth devices.
/// - Optionally including system-paired devices at startup.
/// - Custom filtering logic to only track devices matching certain criteria.
/// - Broadcasting newly discovered devices via a Stream (`newDeviceStream`).
/// - Synchronized device list management to prevent race conditions.
/// - Pause and resume functionality for more control over scanning.
///
/// Usage:
/// ```dart
/// final tracker = BluetoothDevicesTracker();
///
/// // Start tracking with optional system devices and filter
/// tracker.startTracking(
///   getSystemDevices: true,
///   filter: (device) => device.name.startsWith("MyDevice"),
/// );
///
/// // Listen to new device events
/// tracker.newDeviceStream.listen((device) {
///   print('Discovered: ${device.name}');
/// });
///
/// // Later, when done
/// tracker.dispose();
/// ```
///
/// This class is designed for modularity and performance, using a `Set` for fast device lookup
/// and a `Lock` to ensure thread-safe operations during concurrent scan updates.
class BluetoothDevicesTracker {
  final Set<BluetoothDevice> _devices = {};
  final Lock _lock = Lock();

  StreamSubscription? _subscription;
  final StreamController<BluetoothDevice> _newDeviceController = StreamController.broadcast();

  bool _isClosed = false;
  bool _isTracking = false;

  Stream<BluetoothDevice> get newDeviceStream => _newDeviceController.stream;
  Iterable<BluetoothDevice> get devices => _devices;

  TrackingState _state = TrackingState.idle;
  TrackingState get state => _state;

  /// Starts tracking Bluetooth devices
  void startTracking({
    required bool getSystemDevices,
    bool Function(BluetoothDevice)? filter,
  }) {
    if (_isTracking) return;

    _isTracking = true;
    _state = TrackingState.tracking;

    if (getSystemDevices) {
      FlutterBluePlus.systemDevices([]).then((systemDevices) {
        _lock.synchronized(() async {
          for (final device in systemDevices) {
            _handleDevice(device, filter);
          }
        });
      });
    }

    _subscription = FlutterBluePlus.scanResults.listen((results) {
      _lock.synchronized(() async {
        for (final result in results) {
          _handleDevice(result.device, filter);
        }
      });
    });
  }

  /// Internal logic for handling device logic and broadcasting
  void _handleDevice(BluetoothDevice device, bool Function(BluetoothDevice)? filter) {
    if (_devices.contains(device)) return;
    if (filter != null && !filter(device)) return;

    _devices.add(device);
    _newDeviceController.add(device);
  }

  /// Pauses the scanning (stops listening to scan results, but does not clear devices)
  Future<void> pauseTracking() async {
    await FlutterBluePlus.stopScan();
    await _subscription?.cancel();
    _subscription = null;
    _state = TrackingState.stopped;
    _isTracking = false;
  }

  /// Cleanly disposes of resources
  void dispose() {
    if (_isClosed) return;
    _isClosed = true;
    _subscription?.cancel();
    _newDeviceController.close();
    _state = TrackingState.stopped;
  }
}
