import 'dart:async';
import 'dart:typed_data';

part 'bluetooth_packet.dart';

/// Abstract class that defines a contract for any class that provides
/// a stream of BluetoothPacket objects.
///
/// Implementing classes must expose a [bluetoothPacketStream] that emits
/// Bluetooth data packets over time.
abstract class BluetoothDataStreamManager {
  // A stream that emits BluetoothPacket instances.
  Stream<BluetoothPacket> get bluetoothPacketStream;
}
