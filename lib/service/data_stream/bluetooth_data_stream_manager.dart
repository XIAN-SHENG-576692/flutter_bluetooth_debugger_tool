import 'dart:async';
import 'dart:typed_data';

part 'bluetooth_packet.dart';

abstract class BluetoothDataStreamManager {
  Stream<BluetoothPacket> get bluetoothPacketStream;
}
