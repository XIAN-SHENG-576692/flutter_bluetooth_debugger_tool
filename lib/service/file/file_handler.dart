import 'package:flutter_bluetooth_debugger_tool/service/data_stream/data_stream.dart';

part 'bluetooth_packet_file.dart';

abstract class FileHandler {
  Future<BluetoothPacketFile> createBluetoothPacket();
}
