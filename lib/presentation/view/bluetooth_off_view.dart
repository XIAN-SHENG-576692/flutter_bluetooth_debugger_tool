import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/widgets/snackbar.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth_widget.dart';

class BluetoothOffView extends StatelessWidget {
  const BluetoothOffView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA,
      child: BluetoothWidgetOff.buildOffScreen(
        context: context,
        turnOn: FlutterBluePlus.turnOn,
      ),
    );
  }
}
