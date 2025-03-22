import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/bluetooth_is_on_view.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/scanner/bluetooth_device_scanner_tile.dart';
import 'package:provider/provider.dart';

class BluetoothScannerView extends StatelessWidget {
  const BluetoothScannerView({super.key});
  @override
  Widget build(BuildContext context) {
    return BluetoothIsOnView(
      isOnView: Selector<BluetoothScannerChangeNotifier, int>(
        selector: (context, scanner) => scanner.filteredScanResultsBuffer.length,
        builder: (context, length, __) {
          final scanner = context.read<BluetoothScannerChangeNotifier>();
          return RefreshIndicator(
            onRefresh: scanner.refresh,
            child: ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) {
                return BluetoothDeviceScannerTile(
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
