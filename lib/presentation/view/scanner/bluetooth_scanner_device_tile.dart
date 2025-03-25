import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:flutter_cxs_ui_utils/bluetooth/bluetooth.dart';
import 'package:provider/provider.dart';

class _RssiText extends StatelessWidget {
  const _RssiText({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final rssi = context.select<BluetoothScannerDeviceTileChangeNotifier, int>((b) => b.buffer.rssi);
    return Text(rssi.toString());
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final device = context.select<BluetoothScannerDeviceTileChangeNotifier, BluetoothDevice>((b) => b.buffer.bluetoothDevice);
    final connectable = context.select<BluetoothScannerDeviceTileChangeNotifier, bool>((b) => b.buffer.connectable);
    final isConnected = context.select<BluetoothScannerDeviceTileChangeNotifier, bool>((b) => b.buffer.isConnected);
    final themeData = Theme.of(context);
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
  const _SelectButton({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final device = context.select<BluetoothScannerDeviceTileChangeNotifier, BluetoothDevice>((b) => b.buffer.bluetoothDevice);
    final isSelected = context.select<BluetoothDeviceDetailSelectorChangeNotifier, bool>((s) => s.bluetoothDevice == device);
    final deviceSelector = context.read<BluetoothDeviceDetailSelectorChangeNotifier>();
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: (isSelected)
            ? themeData.selectedBluetoothDeviceColor
            : null,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          customBorder: CircleBorder(),
          splashColor: themeData.selectedBluetoothDeviceInkColor,
          highlightColor: themeData.selectedBluetoothDeviceInkColor,
          onTap: () {
            deviceSelector.bluetoothDevice = device;
            deviceSelector.openDeviceDetailView?.call();
          },
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(
              Icons.list_alt,
            ),
          ),
        ),
      ),
    );
  }
}

class BluetoothScannerDeviceTile extends StatelessWidget {
  const BluetoothScannerDeviceTile({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final buffer = context.select<BluetoothScannerDeviceTileChangeNotifier, ScanResultBuffer>((b) => b.buffer);
    final isConnected = context.select<BluetoothScannerDeviceTileChangeNotifier, bool>((b) => b.buffer.isConnected);
    final rssiText = _RssiText();
    final connectionButton = _ConnectionButton();
    final selectButton = _SelectButton();
    final backgroundColor = (isConnected)
        ? themeData.connectedBluetoothDeviceTileColor
        : themeData.disconnectedBluetoothDeviceTileColor;
    final title = BluetoothWidgetDevice.buildTitle(
      context: context,
      deviceName: buffer.deviceName,
      deviceId: buffer.deviceId,
    );
    return ListTile(
      leading: rssiText,
      title: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          connectionButton,
          selectButton,
        ],
      ),
      tileColor: backgroundColor,
    );
  }
}
