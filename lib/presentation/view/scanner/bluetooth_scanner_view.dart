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
        child: ProxyProvider<BluetoothScannerChangeNotifier, Iterable<ScanResultBuffer>>(
          update: (context, scanner, prev) => scanner.filteredScanResultsBuffer,
          builder: (context, _) {
            final buffers = context.watch<Iterable<ScanResultBuffer>>();
            return ListView.builder(
              itemCount: buffers.length,
              itemBuilder: (context, index) {
                return ProxyProvider<Iterable<ScanResultBuffer>, ScanResultBuffer>(
                  update: (context, buffers, prev) => buffers.elementAt(index),
                  builder: (context, _) {
                    return BluetoothScannerDeviceTile();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
