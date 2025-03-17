/// Fetches data from _dataStream.bluetoothPacketStream and writes it to a CSV file.
/// The CSV file is created upon the first write operation.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/data_stream.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:synchronized/synchronized.dart';

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class DataStreamTask {
  final DataStream _dataStream;
  final FileHandler _fileHandler;
  BluetoothPacketFile? _bluetoothPacketFile;
  final Lock _bluetoothPacketFileLock = Lock();
  bool _isSavingBluetoothPacket = false;
  bool get isSavingBluetoothPacket => _isSavingBluetoothPacket;
  final _ChangeNotifier _isSavingBluetoothPacketChangeNotifier = _ChangeNotifier();
  void startSavingBluetoothPacket() {
    _isSavingBluetoothPacket = true;
    _isSavingBluetoothPacketChangeNotifier.notifyListeners();
  }
  void stopSavingBluetoothPacket() {
    _isSavingBluetoothPacket = false;
    _isSavingBluetoothPacketChangeNotifier.notifyListeners();
  }
  void toggleSavingBluetoothPacket() {
    _isSavingBluetoothPacket = !_isSavingBluetoothPacket;
    _isSavingBluetoothPacketChangeNotifier.notifyListeners();
  }
  void addSavingBluetoothPacketListener(void Function() listener) {
    _isSavingBluetoothPacketChangeNotifier.addListener(listener);
  }
  void removeSavingBluetoothPacketListener(void Function() listener) {
    _isSavingBluetoothPacketChangeNotifier.removeListener(listener);
  }

  DataStreamTask({
    required DataStream dataStream,
    required FileHandler fileHandler,
  }) : _fileHandler = fileHandler, _dataStream = dataStream {
    _subscription = _dataStream.bluetoothPacketStream.listen((packet) {
      _bluetoothPacketFileLock.synchronized(() async {
        if(!_isSavingBluetoothPacket) return;
        _bluetoothPacketFile ??= await _fileHandler.createBluetoothPacket();
        await _bluetoothPacketFile?.write(packet);
      });
    });
  }

  late final StreamSubscription _subscription;

  void close() {
    _isSavingBluetoothPacketChangeNotifier.dispose();
    _subscription.cancel();
  }
}
