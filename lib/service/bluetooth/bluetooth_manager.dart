part of 'bluetooth.dart';

abstract class BluetoothManager {
  Iterable<BluetoothDevice> get devices;

  bool get isOn;
  Future turnOn();

  bool get isScanning;
  Future startScan();
  Future rescan();
  Future toggleScan();
}
