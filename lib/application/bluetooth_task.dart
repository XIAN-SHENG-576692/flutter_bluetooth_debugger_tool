/// Fetches data from _dataStream.bluetoothPacketStream and writes it to a CSV file.
/// The CSV file is created upon the first write operation.

import 'dart:async';

import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:synchronized/synchronized.dart';

class BluetoothTask {
  BluetoothPacketFile? _bluetoothPacketFile;
  final Lock _bluetoothPacketFileLock = Lock();
  bool _isSavingBluetoothPacket = false;
  bool get isSavingBluetoothPacket => _isSavingBluetoothPacket;
  final StreamController<bool> _isSavingBluetoothController = StreamController.broadcast();
  Stream<bool> get isSavingBluetoothPacketStream => _isSavingBluetoothController.stream;
  void startSavingBluetoothPacket() {
    _isSavingBluetoothPacket = true;
    _isSavingBluetoothController.add(_isSavingBluetoothPacket);
  }
  void stopSavingBluetoothPacket() {
    _isSavingBluetoothPacket = false;
    _isSavingBluetoothController.add(_isSavingBluetoothPacket);
  }
  void toggleSavingBluetoothPacket() {
    _isSavingBluetoothPacket = !_isSavingBluetoothPacket;
    _isSavingBluetoothController.add(_isSavingBluetoothPacket);
  }

  void _writeFile({
    required BluetoothPacket packet,
    required FileHandler fileHandler,
  }) {
    _bluetoothPacketFileLock.synchronized(() async {
      if(!_isSavingBluetoothPacket) return;
      _bluetoothPacketFile ??= await fileHandler.createBluetoothPacket();
      await _bluetoothPacketFile?.write(packet);
    });
  }

  BluetoothTask({
    required BluetoothDataStreamManager bluetoothDataStreamManager,
    required FileHandler fileHandler,
  }) {
    _subscription = bluetoothDataStreamManager.bluetoothPacketStream.listen((packet) {
      _writeFile(packet: packet, fileHandler: fileHandler);
    });
  }

  late final StreamSubscription _subscription;

  void close() {
    _subscription.cancel();
  }
}
