part of 'bluetooth_data_stream_manager.dart';

class _Mapper {
  _Mapper._();
  static BluetoothPacket fromBluetoothCharacteristicToBluetoothPacket({
    required List<int> value,
    required BluetoothCharacteristic characteristic,
  }) {
    return BluetoothPacket(
      byteBuffer: Uint8List.fromList(value).buffer,
      dateTime: DateTime.now(),
      deviceId: characteristic.device.remoteId.str,
      deviceName: characteristic.device.platformName,
      layer: BluetoothPacketLayer.characteristic,
      layerUuid: characteristic.uuid.str,
    );
  }
  static BluetoothPacket fromBluetoothDescriptorToBluetoothPacket({
    required List<int> value,
    required BluetoothDescriptor descriptor,
  }) {
    return BluetoothPacket(
      byteBuffer: Uint8List.fromList(value).buffer,
      dateTime: DateTime.now(),
      deviceId: descriptor.device.remoteId.str,
      deviceName: descriptor.device.platformName,
      layer: BluetoothPacketLayer.descriptor,
      layerUuid: descriptor.uuid.str,
    );
  }
}
