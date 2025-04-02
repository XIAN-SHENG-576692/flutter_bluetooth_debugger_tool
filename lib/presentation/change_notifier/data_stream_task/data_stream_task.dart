import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_debugger_tool/application/bluetooth_task.dart';

/// A ChangeNotifier wrapper around [BluetoothTask] to support UI updates
/// in Flutter using Provider or other state management tools.
class BluetoothTaskChangeNotifier extends ChangeNotifier {
  // The BluetoothTask instance this notifier is wrapping
  BluetoothTask bluetoothTask;

  /// Constructor: requires a [BluetoothTask] instance
  /// Subscribes to the isSavingBluetoothPacketStream to listen for changes
  /// and notify UI listeners accordingly.
  BluetoothTaskChangeNotifier({
    required this.bluetoothTask,
  }) {
    _subscription = bluetoothTask.isSavingBluetoothPacketStream.listen(
          (_) => notifyListeners(), // Notifies Flutter widgets when saving state changes
    );
  }

  // Stream subscription to the BluetoothTask's saving state
  late final StreamSubscription _subscription;

  /// Getter to expose the current saving state to the UI
  bool get isSaving => bluetoothTask.isSavingBluetoothPacket;

  /// Toggles the saving state: start or stop saving Bluetooth packets
  void toggle() {
    bluetoothTask.toggleSavingBluetoothPacket();
  }

  /// Cleanup method to cancel the stream subscription when the notifier is disposed
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
