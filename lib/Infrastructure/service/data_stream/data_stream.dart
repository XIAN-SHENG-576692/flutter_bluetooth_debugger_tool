import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_cxs_utils/tracker/abstract_bluetooth_device_tracker.dart';
import 'package:flutter_blue_plus_cxs_utils/tracker/custom/custom_bluetooth_device.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/data_stream.dart';

part 'bluetooth_packet_data_stream.dart';

class DataStreamImplFbp extends DataStream {
  final List<DataStreamBluetoothDeviceDiscover> bluetoothDeviceDiscovers = [];
  final AbstractBluetoothDeviceTracker<CustomBluetoothDeviceDiscover> abstractBluetoothDeviceTracker;
  DataStreamImplFbp({
    required this.abstractBluetoothDeviceTracker,
  }) {
    for(final device in abstractBluetoothDeviceTracker.devices) {
      bluetoothDeviceDiscovers.add(DataStreamBluetoothDeviceDiscover(dataStreamImplFbp: this, bluetoothDeviceDiscover: device));
    }
    _newDevicesStreamSubscription = abstractBluetoothDeviceTracker.onCreateNewDeviceStream.listen((device) {
      bluetoothDeviceDiscovers.add(DataStreamBluetoothDeviceDiscover(dataStreamImplFbp: this, bluetoothDeviceDiscover: device));
    });
  }
  late final StreamSubscription _newDevicesStreamSubscription;
  final StreamController<BluetoothPacket> _bluetoothPacketStreamController = StreamController();
  @override
  Stream<BluetoothPacket> get bluetoothPacketStream => _bluetoothPacketStreamController.stream;
  void close() {
    for(final d in bluetoothDeviceDiscovers) {
      d.close();
    }
    _newDevicesStreamSubscription.cancel();
    _bluetoothPacketStreamController.close();
    bluetoothDeviceDiscovers.clear();
  }
}
