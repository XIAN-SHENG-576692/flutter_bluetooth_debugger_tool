import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/data_stream_task/data_stream_task.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:provider/provider.dart';

class _TaskButton extends Consumer<DataStreamTaskChangeNotifier> {
  _TaskButton() : super(
    builder: (context, taskNotifier, child) {
      final themeData = Theme.of(context);
      final isSaving = taskNotifier.isSaving;
      VoidCallback? onPressed = taskNotifier.toggle;
      final icon = (isSaving)
          ? Icon(Icons.stop,)
          : Icon(Icons.save,);
      final color = (isSaving)
          ? themeData.savingDisabledColor
          : themeData.savingEnabledColor;
      return IconButton(
        onPressed: onPressed,
        icon: icon,
        color: color,
        highlightColor: themeData.screenBackgroundColor,
      );
    },
  );
}

class _FilterButton extends Selector<BluetoothScannerChangeNotifier, bool> {
  _FilterButton(BluetoothScannerFilterOption option) : super(
    selector: (_, scanner) => scanner.isSelectedFilterOption(option: option),
    builder: (context, isSelected, child) {
      final scanner = context.read<BluetoothScannerChangeNotifier>();
      final themeData = Theme.of(context);
      late final Icon icon;
      switch(option) {
        case BluetoothScannerFilterOption.nameIsNotEmpty:
          icon = Icon(Icons.list);
          break;
        case BluetoothScannerFilterOption.isScanned:
          icon = Icon(Icons.scanner);
          break;
        case BluetoothScannerFilterOption.isConnected:
          icon = Icon(Icons.link);
          break;
        case BluetoothScannerFilterOption.connectable:
          icon = Icon(Icons.bluetooth_connected);
          break;
      }
      final color = isSelected
          ? themeData.filterEnabledColor
          : null;
      return IconButton(
        onPressed: () => scanner.toggleFilterOption(option: option),
        icon: icon,
        color: color,
        highlightColor: themeData.screenBackgroundColor,
      );
    },
  );
}

class HomeAppBar extends AppBar {
  HomeAppBar({
    super.key,
    required ThemeData themeData,
  }) : super(
    title: Consumer<DataStreamTaskChangeNotifier>(
      builder: (_, taskNotifier, __) {
        return _TaskButton();
      },
    ),
    actions: BluetoothScannerFilterOption.values.map((option) => _FilterButton(option)).toList(),
    backgroundColor: themeData.screenBackgroundColor,
  );
}
