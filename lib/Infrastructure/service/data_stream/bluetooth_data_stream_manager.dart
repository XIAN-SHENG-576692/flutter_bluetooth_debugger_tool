import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';

part 'mapper.dart';

class _ServicesTask {
  BluetoothDevice device;
  List<BluetoothService> services;
  late final StreamSubscription _subscription;
  _ServicesTask({
    required this.device,
    required this.services,
  }) {
    _subscription = device.connectionState.listen((state) {
      if(state == BluetoothConnectionState.disconnected) {
        services.clear();
      }
    });
  }
}

class BluetoothDataStreamManagerImplFbp extends BluetoothDataStreamManager {
  final List<_ServicesTask> _taskList = [];
  BluetoothDataStreamManagerImplFbp();
  final StreamController<BluetoothPacket> _bluetoothPacketStreamController = StreamController();
  void registerTask({
    required BluetoothDevice device,
    required List<BluetoothService> services,
  }) {
    final oldTask = _taskList.where((t) => t.device == device).firstOrNull;
    if(oldTask != null) {
      if(oldTask.services.isNotEmpty) return;
      oldTask.services = services;
    } else {
      _taskList.add(_ServicesTask(
        device: device,
        services: services,
      ));
    }
    for(final s in device.servicesList.toList(growable: false)) {
      for(final c in s.characteristics) {
        device.cancelWhenDisconnected(c.lastValueStream.listen((value) {
          _bluetoothPacketStreamController.add(_Mapper.fromBluetoothCharacteristicToBluetoothPacket(
            value: value,
            characteristic: c,
          ));
        }));
        for(final d in c.descriptors) {
          device.cancelWhenDisconnected(d.lastValueStream.listen((value) {
            _bluetoothPacketStreamController.add(_Mapper.fromBluetoothDescriptorToBluetoothPacket(
              value: value,
              descriptor: d,
            ));
          }));
        }
      }
    }
  }
  @override
  Stream<BluetoothPacket> get bluetoothPacketStream => _bluetoothPacketStreamController.stream;
  void close() {
    _bluetoothPacketStreamController.close();
  }
}
