import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth.dart';
import 'package:provider/provider.dart';

class _RssiText extends Selector<BluetoothScannerChangeNotifier, int> {
  _RssiText({
    required int index,
  }) : super(
    selector: (_, scanner) => scanner.filteredDevices.skip(index).first.rssi,
    builder: (context, rssi, child) {
      return Text(
        rssi.toString(),
      );
    },
  );
}

class _ConnectionButtonStatus extends Equatable {
  bool connectable;
  bool isConnected;
  _ConnectionButtonStatus({
    required this.connectable,
    required this.isConnected,
  });
  @override
  List<Object?> get props => [
    connectable,
    isConnected,
  ];
}

class _ConnectionButton extends Selector<BluetoothScannerChangeNotifier, _ConnectionButtonStatus> {
  _ConnectionButton({
    required int index,
  }) : super(
    selector: (_, scanner) => _ConnectionButtonStatus(
      connectable: scanner.filteredDevices.skip(index).first.connectable,
      isConnected: scanner.filteredDevices.skip(index).first.isConnected,
    ),
    builder: (context, status, child) {
      final connectable = status.connectable;
      final isConnected = status.isConnected;
      final themeData = Theme.of(context);
      final scanner = context.read<BluetoothScannerChangeNotifier>();
      final device = scanner.filteredDevices.skip(index).first;
      VoidCallback? onPressed = (connectable)
          ? device.toggleConnection
          : null;
      final connectionIcon = (isConnected)
          ? Icon(
            Icons.bluetooth_disabled,
          )
          : Icon(
            Icons.bluetooth_connected,
          );
      return IconButton(
        onPressed: onPressed,
        icon: connectionIcon,
        highlightColor: themeData.screenBackgroundColor,
      );
    },
  );
}

class _SelectButton extends StatelessWidget {
  final int index;
  const _SelectButton({
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final scanner = context.read<BluetoothScannerChangeNotifier>();
    final device = scanner.filteredDevices.skip(index).first;
    return IconButton(
      onPressed: device.checkDetail,
      icon: Icon(
        Icons.list_alt,
      ),
      highlightColor: themeData.screenBackgroundColor,
    );
  }
}

class _BluetoothDeviceScannerTileStatus extends Equatable {
  bool isConnected;
  bool isSelected;
  _BluetoothDeviceScannerTileStatus({
    required this.isConnected,
    required this.isSelected,
  });
  @override
  List<Object?> get props => [
    isConnected,
    isSelected,
  ];
}

class BluetoothDeviceScannerTile extends Selector<BluetoothScannerChangeNotifier, _BluetoothDeviceScannerTileStatus> {
  final int index;
  BluetoothDeviceScannerTile({
    super.key,
    required this.index,
  }) : super(
    selector: (_, scanner) => _BluetoothDeviceScannerTileStatus(
      isConnected: scanner.filteredDevices.skip(index).first.isConnected,
      isSelected: scanner.filteredDevices.skip(index).first.isSelected,
    ),
    builder: (context, status, child) {
      final isConnected = status.isConnected;
      final isSelected = status.isSelected;
      final scanner = context.read<BluetoothScannerChangeNotifier>();
      final device = scanner.filteredDevices.skip(index).first;
      final themeData = Theme.of(context);
      final rssiText = _RssiText(
        index: index,
      );
      final connectionButton = _ConnectionButton(
        index: index,
      );
      final selectButton = _SelectButton(
        index: index,
      );
      var backgroundColor = (isConnected)
        ? themeData.connectedBluetoothDeviceTileColor
        : themeData.disconnectedBluetoothDeviceTileColor;
      if(isSelected) backgroundColor = themeData.selectedBluetoothDevice;
      final title = BluetoothWidgetDevice.buildTitle(
        context: context,
        deviceName: device.deviceName,
        deviceId: device.deviceId,
      );
      return ListTile(
        leading: rssiText,
        title: title,
        trailing: (isConnected)
          ? selectButton
          : connectionButton,
        tileColor: backgroundColor,
      );
    },
  );
}
