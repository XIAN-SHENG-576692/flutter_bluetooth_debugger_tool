part of 'data_stream.dart';

enum BluetoothPacketLayer {
  characteristic,
  descriptor,
}

class BluetoothPacket {
  ByteBuffer byteBuffer;
  final DateTime dateTime;
  final String deviceId;
  final String deviceName;
  BluetoothPacketLayer layer;
  String layerUuid;
  BluetoothPacket({
    required this.byteBuffer,
    required this.dateTime,
    required this.deviceId,
    required this.deviceName,
    required this.layer,
    required this.layerUuid,
  });
}
