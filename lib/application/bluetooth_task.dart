import 'dart:async';

import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:synchronized/synchronized.dart';

/// Fetches data from BluetoothDataStreamManager then writes it to a CSV file.
/// The CSV file is created upon the startSavingBluetoothPacket function be triggered.
class BluetoothTask {
  // A reference to the file where Bluetooth packets will be saved
  BluetoothPacketFile? _bluetoothPacketFile;

  // A lock to ensure thread-safe access to the file and save flag
  final Lock _bluetoothPacketFileLock = Lock();

  // Boolean flag indicating whether packets are currently being saved
  bool _isSavingBluetoothPacket = false;

  // Public getter to expose the saving status
  bool get isSavingBluetoothPacket => _isSavingBluetoothPacket;

  // Stream controller to notify UI or listeners when saving status changes
  final StreamController<bool> _isSavingBluetoothController = StreamController.broadcast();

  // Stream to listen for saving status changes
  Stream<bool> get isSavingBluetoothPacketStream => _isSavingBluetoothController.stream;

  // Start saving Bluetooth packets
  void startSavingBluetoothPacket() {
    _bluetoothPacketFileLock.synchronized(() async {
      _isSavingBluetoothPacket = true;
      _isSavingBluetoothController.add(_isSavingBluetoothPacket); // Notify listeners
    });
  }

  // Stop saving Bluetooth packets and clear the file reference
  void stopSavingBluetoothPacket() {
    _bluetoothPacketFileLock.synchronized(() async {
      _isSavingBluetoothPacket = false;
      _bluetoothPacketFile = null;
      _isSavingBluetoothController.add(_isSavingBluetoothPacket); // Notify listeners
    });
  }

  // Toggle the saving state: start if currently stopped, stop if currently started
  void toggleSavingBluetoothPacket() {
    return (_isSavingBluetoothPacket)
        ? stopSavingBluetoothPacket()
        : startSavingBluetoothPacket();
  }

  // Private method to write a Bluetooth packet to file if saving is enabled
  void _writeFile({
    required BluetoothPacket packet,
    required FileHandler fileHandler,
  }) {
    _bluetoothPacketFileLock.synchronized(() async {
      if(!_isSavingBluetoothPacket) return; // Skip if not saving
      _bluetoothPacketFile ??= await fileHandler.createBluetoothPacket(); // Create file if not already
      await _bluetoothPacketFile?.write(packet); // Write packet to file
    });
  }

  // Constructor: subscribe to Bluetooth packet stream and write data to file if saving
  BluetoothTask({
    required BluetoothDataStreamManager bluetoothDataStreamManager,
    required FileHandler fileHandler,
  }) {
    _subscription = bluetoothDataStreamManager.bluetoothPacketStream.listen((packet) {
      _writeFile(packet: packet, fileHandler: fileHandler); // Handle each incoming packet
    });
  }

  // Subscription to the Bluetooth stream
  late final StreamSubscription _subscription;

  // Cancel the stream subscription to release resources
  void close() {
    _subscription.cancel();
  }
}
