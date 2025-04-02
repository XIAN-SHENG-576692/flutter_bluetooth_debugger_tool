import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';

part 'bluetooth_packet_file.dart';

/// Abstract class that defines the interface for file handling
/// related to saving Bluetooth packets.
///
/// Implementing classes must define how a [BluetoothPacketFile] is created.
abstract class FileHandler {
  /// Creates and returns a [BluetoothPacketFile] instance.
  /// This file will be used to store Bluetooth packets.
  Future<BluetoothPacketFile> createBluetoothPacket();
}
