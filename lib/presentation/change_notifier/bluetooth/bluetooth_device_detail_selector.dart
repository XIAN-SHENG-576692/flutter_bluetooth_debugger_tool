part of 'bluetooth.dart';

/// A ChangeNotifier that manages the currently selected Bluetooth device
/// for displaying its detailed information in the UI.
class BluetoothDeviceDetailSelectorChangeNotifier extends ChangeNotifier {
  // Holds the currently selected Bluetooth device.
  BluetoothDevice? _bluetoothDevice;

  // Optional callback to trigger opening the device detail view.
  VoidCallback? openDeviceDetailView;

  /// Constructor with optional initial Bluetooth device and view callback.
  BluetoothDeviceDetailSelectorChangeNotifier({
    BluetoothDevice? bluetoothDevice,
    this.openDeviceDetailView,
  }) : _bluetoothDevice = bluetoothDevice;

  /// Setter for changing the selected Bluetooth device.
  /// Only triggers listeners if the new device is different from the current one.
  set bluetoothDevice(BluetoothDevice? newDevice) {
    if (_bluetoothDevice == newDevice) return;
    _bluetoothDevice = newDevice;
    notifyListeners(); // Notify UI or other listeners of the change
  }

  /// Getter for accessing the currently selected Bluetooth device.
  BluetoothDevice? get bluetoothDevice => _bluetoothDevice;
}
