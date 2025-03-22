import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';

part 'bluetooth_packet_file.dart';

abstract class FileHandler {
  Future<BluetoothPacketFile> createBluetoothPacket();
}
