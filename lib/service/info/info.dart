import '../../presentation/change_notifier/bluetooth/bluetooth.dart';

abstract class Info {
  Future<bool> setFilterOption(BluetoothScannerFilterOption option, bool value);
  Future<bool?> getFilterOption(BluetoothScannerFilterOption option);
}
