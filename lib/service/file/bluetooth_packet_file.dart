part of 'file_handler.dart';

abstract class BluetoothPacketFile {
  Future<bool> write(BluetoothPacket packet);
}
