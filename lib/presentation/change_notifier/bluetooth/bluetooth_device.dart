part of 'bluetooth.dart';

abstract class BluetoothDeviceStatus {
  bool get isConnected;
  bool get connectable;
  String get deviceName;
  String get deviceId;
  int get rssi;
  bool get isScanned;
  bool get isSelected;
  void toggleConnection();
  void checkDetail();
}
