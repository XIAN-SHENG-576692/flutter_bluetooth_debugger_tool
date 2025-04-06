import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'devices/bluetooth_devices_tracker.dart';
import 'services/bluetooth_services_auto_tracker.dart';
import 'services/bluetooth_services_tracker.dart';

class BluetoothModule {
  final BluetoothDevicesTracker bluetoothDevicesTracker = BluetoothDevicesTracker();
  final BluetoothServicesTracker bluetoothServicesTracker = BluetoothServicesTracker();
  late final BluetoothServicesAutoTracker bluetoothServicesAutoTracker;
  BluetoothModule() {
    bluetoothServicesAutoTracker = BluetoothServicesAutoTracker(
      bluetoothServicesTracker: bluetoothServicesTracker,
      bluetoothDevicesTracker: bluetoothDevicesTracker,
      shouldAutoDiscover: (_) => false,
    );
    bluetoothDevicesTracker.startTracking(
      getSystemDevices: true,
    );
  }
  Future<bool> discover({required BluetoothDevice device,}) async {
    return (await bluetoothServicesTracker.buffers.where((b) => b.device == device).firstOrNull?.discover()) ?? false;
  }
  List<BluetoothService> getBluetoothServices({required BluetoothDevice device}) {
    return bluetoothServicesTracker.buffers.where((b) => b.device == device).firstOrNull?.services ?? [];
  }
  Stream<BluetoothServicesBuffer> get updatedServicesStream => bluetoothServicesTracker.updatedServicesStream;
}
