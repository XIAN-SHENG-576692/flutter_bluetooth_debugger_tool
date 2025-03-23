import 'package:flutter/material.dart';

extension AppThemeData on ThemeData {
  Color get screenBackgroundColor => brightness == Brightness.light
      ? Colors.white
      : Colors.black;
  Color get bluetoothColor => brightness == Brightness.light
      ? Colors.blue
      : Colors.indigoAccent;
  Color get connectedBluetoothDeviceTileColor => bluetoothColor;
  Color get disconnectedBluetoothDeviceTileColor => brightness == Brightness.light
      ? Colors.red
      : Colors.red[900]!;
  Color get stopScanningBluetoothButtonColor => disconnectedBluetoothDeviceTileColor;
  Color get selectedBluetoothDeviceColor => screenBackgroundColor;
  Color get selectedBluetoothDeviceInkColor => brightness == Brightness.light
      ? Colors.black
      : Colors.white;
  Color get savingEnabledColor => brightness == Brightness.light
      ? Colors.green
      : Colors.green[700]!;
  Color get savingDisabledColor => brightness == Brightness.light
      ? Colors.red
      : Colors.red[700]!;
  Color get filterEnabledColor => brightness == Brightness.light
      ? Colors.orange
      : Colors.orange[700]!;
}
