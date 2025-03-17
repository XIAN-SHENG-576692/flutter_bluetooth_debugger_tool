import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_debugger_tool/application/data_stream_task.dart';

class DataStreamTaskChangeNotifier extends ChangeNotifier {
  final DataStreamTask _dataStreamTask;
  DataStreamTaskChangeNotifier(this._dataStreamTask) {
    _dataStreamTask.addSavingBluetoothPacketListener(notifyListeners);
  }
  bool get isSaving => _dataStreamTask.isSavingBluetoothPacket;
  void toggle() {
    _dataStreamTask.toggleSavingBluetoothPacket();
  }
}
