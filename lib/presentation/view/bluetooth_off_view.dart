import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart' show BluetoothScannerChangeNotifier;
import 'package:flutter_bluetooth_debugger_tool/presentation/fbp/utils/snackbar.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth_widget.dart';
import 'package:provider/provider.dart';

class BluetoothOffView extends Selector<BluetoothScannerChangeNotifier, bool> {
  BluetoothOffView({
    super.key,
  }) : super(
    selector: (_, scanner) => scanner.isOn,
    builder: (context, isOn, _) {
      final scanner = context.read<BluetoothScannerChangeNotifier>();
      return ScaffoldMessenger(
        key: Snackbar.snackBarKeyA,
        child: BluetoothWidgetOff.buildOffScreen(
          context: context,
          turnOn: scanner.turnOn,
        ),
      );
    },
  );
}
