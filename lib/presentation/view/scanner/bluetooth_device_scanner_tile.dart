import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth.dart';
import 'package:provider/provider.dart';

class _RssiText extends StatelessWidget {
  final int index;
  const _RssiText({
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final isValid = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.length > index);
    if(!isValid) return Column();
    final rssi = context.select<BluetoothScannerChangeNotifier, int>((b) => b.filteredScanResultsBuffer.elementAt(index).rssi);
    return Text(rssi.toString());
  }
}

class _ConnectionButton extends StatelessWidget {
  final int index;
  const _ConnectionButton({
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final isValid = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.length > index);
    if(!isValid) return Column();
    final themeData = Theme.of(context);
    final device = context.select<BluetoothScannerChangeNotifier, BluetoothDevice>((b) => b.filteredScanResultsBuffer.elementAt(index).bluetoothDevice);
    final isConnected = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.elementAt(index).bluetoothDevice.isConnected);
    final connectable = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.elementAt(index).connectable);
    VoidCallback? onPressed = (connectable)
      ? () async {
        try{
          (isConnected)
            ? await device.disconnect()
            : await device.connect();
        } catch(e) {}
      }
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
  }
}

class _SelectButton extends StatelessWidget {
  final int index;
  const _SelectButton({
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final isValid = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.length > index);
    if(!isValid) return Column();
    final themeData = Theme.of(context);
    final device = context.select<BluetoothScannerChangeNotifier, BluetoothDevice>((b) => b.filteredScanResultsBuffer.elementAt(index).bluetoothDevice);
    final isSelected = context.select<BluetoothDeviceDetailSelectorChangeNotifier, bool>((s) => s.bluetoothDevice == device);
    final deviceSelector = context.read<BluetoothDeviceDetailSelectorChangeNotifier>();
    return IconButton(
      onPressed: () => (isSelected)
        ? deviceSelector.openDeviceDetailView?.call()
        : deviceSelector.bluetoothDevice = device,
      icon: Icon(
        Icons.list_alt,
      ),
      highlightColor: themeData.screenBackgroundColor,
    );
  }
}

class BluetoothDeviceScannerTile extends StatelessWidget {
  final int index;
  const BluetoothDeviceScannerTile({
    super.key,
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    final isValid = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.length > index);
    if(!isValid) return Column();
    final themeData = Theme.of(context);
    final device = context.select<BluetoothScannerChangeNotifier, BluetoothDevice>((b) => b.filteredScanResultsBuffer.elementAt(index).bluetoothDevice);
    final isConnected = context.select<BluetoothScannerChangeNotifier, bool>((b) => b.filteredScanResultsBuffer.elementAt(index).bluetoothDevice.isConnected);
    final isSelected = context.select<BluetoothDeviceDetailSelectorChangeNotifier, bool>((s) => s.bluetoothDevice == device);
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
      deviceName: device.platformName,
      deviceId: device.remoteId.str,
    );
    return ListTile(
      leading: rssiText,
      title: title,
      trailing: (isConnected)
          ? selectButton
          : connectionButton,
      tileColor: backgroundColor,
    );
  }
}
