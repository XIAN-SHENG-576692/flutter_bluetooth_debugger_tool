import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/bluetooth_is_on_view.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/scanner/bluetooth_scanner_device_tile.dart';
import 'package:provider/provider.dart';

class BluetoothScannerView extends StatelessWidget {
  const BluetoothScannerView({super.key});
  @override
  Widget build(BuildContext context) {
    final scanner = context.read<BluetoothScannerChangeNotifier>();
    return BluetoothIsOnView(
      isOnView: RefreshIndicator(
        onRefresh: scanner.refresh,
        child: Selector<BluetoothScannerChangeNotifier, int>(
          selector: (context, scanner) => scanner.filteredScanResultsBuffer.length,
          builder: (context, length, _) {
            return ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) {
                return ChangeNotifierProvider<BluetoothScannerDeviceTileChangeNotifier>(
                  create: (_) => BluetoothScannerDeviceTileChangeNotifier(scanner: scanner, index: index),
                  child: BluetoothScannerDeviceTile(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
