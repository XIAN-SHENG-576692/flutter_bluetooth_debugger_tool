import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/app_bar/home_app_bar.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/scanner/bluetooth_scanner_view.dart';
import 'package:provider/provider.dart';

import '../change_notifier/bluetooth/bluetooth.dart';
import '../view/detail/device_detail_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const double dragHandleSize = 30;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BluetoothDeviceDetailSelectorChangeNotifier(
            openDeviceDetailView: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        ChangeNotifierProvider<BluetoothScannerChangeNotifier>(create: (_) => BluetoothScannerChangeNotifier()),
        ChangeNotifierProvider<BluetoothDeviceDetailSelectorChangeNotifier>(create: (_) => BluetoothDeviceDetailSelectorChangeNotifier()),
      ],
      child: Scaffold(
        appBar: HomeAppBar(
          themeData: themeData,
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.85,
          child: DeviceDetailView(),
        ),
        body: Builder(
          builder: (context) {
            context.read<BluetoothDeviceDetailSelectorChangeNotifier>().openDeviceDetailView = Scaffold.of(context).openDrawer;
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.localPosition.dx < MediaQuery.of(context).size.width * 0.5 &&
                    details.primaryDelta! > 10) {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: BluetoothScannerView(),
            );
          },
        ),
      ),
    );
  }
}
