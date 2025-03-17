part of 'bluetooth.dart';

enum BluetoothScannerFilterOption {
  nameIsNotEmpty,
  isScanned,
  isConnected,
  connectable,
}

abstract class BluetoothScannerChangeNotifier implements ChangeNotifier {
  Iterable<BluetoothDeviceStatus> get filteredDevices;

  bool isSelectedFilterOption({
    required BluetoothScannerFilterOption option,
  });
  void toggleFilterOption({
    required BluetoothScannerFilterOption option,
  });

  bool get isOn;
  Future turnOn();

  bool get isScanning;
  Future startScan();
  Future rescan();
  Future toggleScan();

  BluetoothDeviceDetailStatus? get selectedDevice;
}
