import 'package:flutter_bluetooth_debugger_tool/service/info/info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/change_notifier/bluetooth/bluetooth.dart';

class InfoImpl extends Info {
  final SharedPreferences sharedPreferences;
  InfoImpl({
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
