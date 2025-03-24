import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/change_notifier/bluetooth/bluetooth.dart';
import '../../../service/user_info/user_preferences.dart';

class UserPreferencesImpl extends UserPreferences {
  final SharedPreferences sharedPreferences;
  UserPreferencesImpl({
    required this.sharedPreferences,
  });
  @override
  Future<bool> setFilterOption(BluetoothScannerFilterOption option, bool value) {
    return sharedPreferences.setBool(option.name, value);
  }
  @override
  Future<bool?> getFilterOption(BluetoothScannerFilterOption option) async {
    return sharedPreferences.getBool(option.name);
  }
}
