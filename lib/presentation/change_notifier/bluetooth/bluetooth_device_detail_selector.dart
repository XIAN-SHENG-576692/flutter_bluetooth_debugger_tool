part of 'bluetooth.dart';

class BluetoothDeviceDetailSelectorChangeNotifier extends ChangeNotifier {
  BluetoothDevice? _bluetoothDevice;
  VoidCallback? openDeviceDetailView;
  BluetoothDeviceDetailSelectorChangeNotifier({
    BluetoothDevice? bluetoothDevice,
    this.openDeviceDetailView,
  }) : _bluetoothDevice = bluetoothDevice;
  set bluetoothDevice(BluetoothDevice? newDevice) {
    if(_bluetoothDevice == newDevice) return;
    _bluetoothDevice = newDevice;
    notifyListeners();
  }
  BluetoothDevice? get bluetoothDevice => _bluetoothDevice;
}
