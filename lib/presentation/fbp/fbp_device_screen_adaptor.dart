import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart' show BluetoothDeviceDetailStatus, BluetoothScannerChangeNotifier;
import 'package:flutter_bluetooth_debugger_tool/presentation/fbp/view/device_screen.dart' show DeviceScreen;
import 'package:provider/provider.dart' show Selector;

class FbpDeviceScreenAdaptor extends Selector<BluetoothScannerChangeNotifier, BluetoothDeviceDetailStatus?> {
  FbpDeviceScreenAdaptor({
    super.key,
  }) : super(
    selector: (_, scanner) => scanner.selectedDevice,
    builder: (_, selectedDevice, __) {
      if(selectedDevice == null) return Scaffold();
      return DeviceScreen(
        bluetoothDeviceDetailStatus: selectedDevice,
      );
    },
  );
}
