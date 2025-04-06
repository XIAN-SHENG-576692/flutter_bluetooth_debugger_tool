import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';

import '../../data/bluetooth_module.dart';

part 'mapper.dart';

class BluetoothDataStreamManagerImplFbp extends BluetoothDataStreamManager {
  final BluetoothModule bluetoothModule;
  late final StreamSubscription _updatedServicesSubscription;
  BluetoothDataStreamManagerImplFbp({
    required this.bluetoothModule,
  }) {
    _updatedServicesSubscription = bluetoothModule.updatedServicesStream.listen((buffer) {
      final services = buffer.services.toList(growable: false);
      final device = buffer.device;
      for(final s in services) {
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
    });
  }
  final StreamController<BluetoothPacket> _bluetoothPacketStreamController = StreamController();
  @override
  Stream<BluetoothPacket> get bluetoothPacketStream => _bluetoothPacketStreamController.stream;
  void close() {
    _updatedServicesSubscription.cancel();
    _bluetoothPacketStreamController.close();
  }
}
