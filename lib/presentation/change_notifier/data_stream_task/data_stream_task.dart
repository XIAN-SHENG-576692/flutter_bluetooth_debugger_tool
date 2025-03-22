import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_debugger_tool/application/bluetooth_task.dart';

class BluetoothTaskChangeNotifier extends ChangeNotifier {
  BluetoothTask bluetoothTask;
  BluetoothTaskChangeNotifier({
    required this.bluetoothTask,
  }) {
    _subscription = bluetoothTask.isSavingBluetoothPacketStream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _subscription;
  bool get isSaving => bluetoothTask.isSavingBluetoothPacket;
  void toggle() {
    bluetoothTask.toggleSavingBluetoothPacket();
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
