import '../../presentation/change_notifier/bluetooth/bluetooth.dart';

abstract class UserPreferences {
  // save filter option to local database.
  Future<bool> setFilterOption(BluetoothScannerFilterOption option, bool value);
  // get filter option from local database.
  Future<bool?> getFilterOption(BluetoothScannerFilterOption option);
}
