part of 'bluetooth.dart';

abstract class BluetoothDevice {
  String get deviceName;
  String get deviceId;

  int get rssi;
  Stream<int> get rssiStream;

  int get mtu;
  Stream<int> get mtuStream;
  Future<int> requestMtu(int mtu);

  Future<bool> toggleConnection();
  bool get isConnected;
  bool get connectable;

  bool get isScanned;
}
