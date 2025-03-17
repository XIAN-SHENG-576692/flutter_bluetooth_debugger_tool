import 'dart:async';
import 'dart:typed_data';

part 'bluetooth_packet.dart';

abstract class DataStream {
  Stream<BluetoothPacket> get bluetoothPacketStream;
}
