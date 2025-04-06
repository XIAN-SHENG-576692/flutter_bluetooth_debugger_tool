import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/widgets.dart';

import '../devices/bluetooth_devices_tracker.dart';
import 'bluetooth_services_tracker.dart';

/// Automatically listens to new devices discovered by [BluetoothDevicesTracker]
/// and registers them into the [BluetoothServicesTracker] with auto-discovery enabled.
/// Also handles service discovery again when device reconnects.
class BluetoothServicesAutoTracker {
  final BluetoothDevicesTracker bluetoothDevicesTracker;
  final BluetoothServicesTracker bluetoothServicesTracker;

  // Subscription to listen to new Bluetooth devices
  late final StreamSubscription _newDeviceSubscription;

  /// Refer to [BluetoothServicesTracker.register]
  @protected
  final bool Function(BluetoothServicesBuffer buffer) shouldAutoDiscover;

  BluetoothServicesAutoTracker({
    required this.bluetoothServicesTracker,
    required this.bluetoothDevicesTracker,
    required this.shouldAutoDiscover,
  }) {
    // Listen for any new devices discovered and register them
    _newDeviceSubscription = bluetoothDevicesTracker.newDeviceStream.listen(register);
  }

  /// Registers the device to service tracker and listens to reconnection events
  void register(BluetoothDevice device) {
    // Auto-discover services for new device
    bluetoothServicesTracker.register(
      device: device,
      shouldAutoDiscover: shouldAutoDiscover,
    );
  }

  /// Cancels all active subscriptions and cleans up
  void cancel() {
    _newDeviceSubscription.cancel();
  }
}
