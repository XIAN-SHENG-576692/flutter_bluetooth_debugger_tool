part of 'bluetooth.dart';

class BluetoothDeviceStatusImplFbp implements BluetoothDeviceStatus {
  BluetoothDevice bluetoothDevice;
  BluetoothScannerChangeNotifierImplFbp scannerChangeNotifierImplFbp;
  BluetoothDeviceStatusImplFbp({
    required this.scannerChangeNotifierImplFbp,
    required this.bluetoothDevice,
  });
  @override
  bool get isConnected => bluetoothDevice.isConnected;
  @override
  bool get connectable => bluetoothDevice.connectable;
  @override
  String get deviceName => bluetoothDevice.deviceName;
  @override
  String get deviceId => bluetoothDevice.deviceId;
  @override
  int get rssi => bluetoothDevice.rssi;
  @override
  bool get isScanned => bluetoothDevice.isScanned;
  @override
  bool get isSelected => scannerChangeNotifierImplFbp.selectedDevice?.bluetoothDevice == bluetoothDevice;
  @override
  void toggleConnection() {
    bluetoothDevice.toggleConnection();
  }
  @override
  void checkDetail() {
    scannerChangeNotifierImplFbp.setSelectedDevice(bluetoothDevice);
  }
}
