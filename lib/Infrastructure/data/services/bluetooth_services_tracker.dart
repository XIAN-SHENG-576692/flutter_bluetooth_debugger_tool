import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Buffer to hold discovered services for a Bluetooth device,
/// and automatically manage service discovery based on connection state.
class BluetoothServicesBuffer {
  final BluetoothServicesTracker _tracker;
  final BluetoothDevice device;
  List<BluetoothService> services = [];

  /// Whether to automatically trigger discovery when the device connects.
  @protected
  final bool Function(BluetoothServicesBuffer buffer) shouldAutoDiscover;

  // Constructor (private), used only by the tracker.
  BluetoothServicesBuffer._({
    required BluetoothServicesTracker tracker,
    required this.device,
    required this.shouldAutoDiscover,
  }) : _tracker = tracker {
    // Listen to connection state of the device
    _connectionStateSubscription = device.connectionState.listen((state) {
      switch (state) {
        case BluetoothConnectionState.disconnected:
        // Clear services if disconnected
          services.clear();
          _tracker._controller.add(
            _StreamControllerBuffer(
              buffer: this,
              option: _BufferOption.updatedServices,
            ),
          );
          break;
        case BluetoothConnectionState.connected:
        // Check whether services should be discovered automatically upon connection.
          if (shouldAutoDiscover(this)) discover();
          break;
        default:
          return;
      }
    });
  }

  late final StreamSubscription _connectionStateSubscription;

  /// Manually trigger service discovery
  Future<bool> discover() async {
    try {
      if(services.isNotEmpty) return true;
      services = await device.discoverServices();
      _tracker._controller.add(
        _StreamControllerBuffer(
          buffer: this,
          option: _BufferOption.updatedServices,
        ),
      );
      return true;
    } catch (e, stack) {
      // Log the error for debugging
      print("Service discovery failed: $e");
      return false;
    }
  }

  /// Cancel the internal subscription to connection state
  void cancel() {
    _connectionStateSubscription.cancel();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is BluetoothServicesBuffer &&
              runtimeType == other.runtimeType &&
              device == other.device);
}

/// Enum to distinguish stream events: new buffer or service updated
enum _BufferOption {
  newBuffer,
  updatedServices,
}

/// Internal class to wrap stream events (buffer + option)
class _StreamControllerBuffer {
  final BluetoothServicesBuffer buffer;
  final _BufferOption option;
  _StreamControllerBuffer({
    required this.buffer,
    required this.option,
  });
}

/// Tracker class to manage service discovery across multiple devices.
/// - Creates buffers per device
/// - Emits events for new buffers and updated services
class BluetoothServicesTracker {
  final Set<BluetoothServicesBuffer> _buffers = {};
  Iterable<BluetoothServicesBuffer> get buffers => _buffers;

  final StreamController<_StreamControllerBuffer> _controller = StreamController.broadcast();

  // Stream of updated services
  Stream<BluetoothServicesBuffer> get updatedServicesStream =>
      _controller.stream
          .where((b) => b.option == _BufferOption.updatedServices)
          .map((b) => b.buffer);

  // Stream of new buffer registrations
  Stream<BluetoothServicesBuffer> get newBufferStream =>
      _controller.stream
          .where((b) => b.option == _BufferOption.newBuffer)
          .map((b) => b.buffer);

  BluetoothServicesTracker();

  /// Register a device to be tracked for services
  void register({
    required BluetoothDevice device,
    required bool Function(BluetoothServicesBuffer buffer) shouldAutoDiscover,
  }) {
    var existing = _buffers.where((b) => b.device == device).firstOrNull;

    if (existing == null) {
      final buffer = BluetoothServicesBuffer._(
        tracker: this,
        device: device,
        shouldAutoDiscover: shouldAutoDiscover,
      );
      _buffers.add(buffer);
      _controller.add(
        _StreamControllerBuffer(
          buffer: buffer,
          option: _BufferOption.newBuffer,
        ),
      );
    }
  }

  /// Unregister a device and cancel its buffer
  void unregister(BluetoothDevice device) {
    var buffer = _buffers.where((b) => b.device == device).firstOrNull;
    if (buffer != null) {
      buffer.cancel();
      _buffers.remove(buffer);
    }
  }

  /// Clean up all resources and subscriptions
  void close() {
    _controller.close();
    for (final b in _buffers) {
      b.cancel();
    }
    _buffers.clear();
  }
}
