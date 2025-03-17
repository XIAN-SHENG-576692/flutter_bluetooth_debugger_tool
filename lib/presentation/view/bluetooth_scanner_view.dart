import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/bluetooth_off_view.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/widgets/bluetooth_device_scanner_tile.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth.dart';
import 'package:provider/provider.dart';

class BluetoothScannerView extends StatelessWidget {
  const BluetoothScannerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<BluetoothScannerChangeNotifier, bool>(
      selector: (_, scanner) => scanner.isOn,
      builder: (context, isOn, _) {
        if(!isOn) return BluetoothOffView();
        final scanner = context.read<BluetoothScannerChangeNotifier>();
        return BluetoothWidgetScan.buildScanner(
          rescan: scanner.rescan,
          devices: Selector<BluetoothScannerChangeNotifier, int>(
            selector: (_, scanner) => scanner.filteredDevices.length,
            builder: (context, devicesLength, _) {
              return ListView.builder(
                itemCount: devicesLength,
                itemBuilder: (context, index) {
                  return BluetoothDeviceScannerTile(
                    index: index,
                  );
                },
              );
            },
          ),
          floatingScanButton: Selector<BluetoothScannerChangeNotifier, bool>(
            selector: (_, scanner) => scanner.isScanning,
            builder: (context, isScanning, _) {
              return BluetoothWidgetScan.buildFloatingScanButton(
                isScanning: isScanning,
                toggleScan: scanner.toggleScan,
              );
            },
          ),
        );
      },
    );
  }
}
