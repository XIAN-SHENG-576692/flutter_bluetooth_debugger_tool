/// Subscribes to the lastValueStream of every characteristic and descriptor whenever a device is discovered.
/// Clears the subscription if the device is disconnected.
part of 'data_stream.dart';

class DataStreamBluetoothDeviceDiscover {
  final DataStreamImplFbp dataStreamImplFbp;
  final CustomBluetoothDeviceDiscover bluetoothDeviceDiscover;
  late final StreamSubscription _clearLastValueStreamSubscription;
  late final StreamSubscription _readPacketSubscription;
  DataStreamBluetoothDeviceDiscover({
    required this.dataStreamImplFbp,
    required this.bluetoothDeviceDiscover,
  }) {
    _clearLastValueStreamSubscription = bluetoothDeviceDiscover.onClearBluetoothServicesStream.listen((_) {
      _clearLastValueStreamSubscriptions();
    });
    _readPacketSubscription = bluetoothDeviceDiscover.onDiscoverBluetoothServicesStream.listen((_) {
      _readPacket();
    });
  }
  void _readPacket() {
    for(final service in bluetoothDeviceDiscover.bluetoothServices.toList()) {
      for(final characteristic in service.characteristics.toList()) {
        _lastValueStreamSubscriptions.add(
            characteristic.lastValueStream.listen((value) {
              _outputLastValue(value: value, device: characteristic.device, layer: BluetoothPacketLayer.characteristic, uuid: characteristic.uuid.str128);
            })
        );
        for(final descriptor in characteristic.descriptors.toList()) {
          _lastValueStreamSubscriptions.add(
              descriptor.lastValueStream.listen((value) {
                _outputLastValue(value: value, device: descriptor.device, layer: BluetoothPacketLayer.descriptor, uuid: descriptor.uuid.str128);
              })
          );
        }
      }
    }
  }
  void _outputLastValue({
    required List<int> value,
    required BluetoothDevice device,
    required BluetoothPacketLayer layer,
    required String uuid,
  }) {
    dataStreamImplFbp._bluetoothPacketStreamController.add(BluetoothPacket(
      byteBuffer: Uint8List.fromList(value).buffer,
      dateTime: DateTime.now(),
      deviceId: device.remoteId.str,
      deviceName: device.platformName,
      layer: BluetoothPacketLayer.characteristic,
      layerUuid: uuid,
    ));
  }
  void _clearLastValueStreamSubscriptions() {
    for(final s in _lastValueStreamSubscriptions) {
      s.cancel();
    }
    _lastValueStreamSubscriptions.clear();
  }
  final List<StreamSubscription<List<int>>> _lastValueStreamSubscriptions = [];
  void close() {
    _clearLastValueStreamSubscriptions();
    _clearLastValueStreamSubscription.cancel();
    _readPacketSubscription.cancel();
  }
}
