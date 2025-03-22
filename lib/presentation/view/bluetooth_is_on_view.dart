import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/bluetooth_off_view.dart';
import 'package:provider/provider.dart';

class BluetoothIsOnView extends StatelessWidget {
  Widget isOnView;
  BluetoothIsOnView({
    super.key,
    required this.isOnView,
  });
  @override
  Widget build(BuildContext context) {
    return StreamProvider<BluetoothAdapterState>(
      create: (_) => FlutterBluePlus.adapterState,
      initialData: FlutterBluePlus.adapterStateNow,
      child: Selector<BluetoothAdapterState, bool>(
        selector: (_, state) => state == BluetoothAdapterState.on,
        builder: (_, isOn, __) {
          return (isOn)
            ? isOnView
            : BluetoothOffView();
        },
      ),
    );
  }
}
