import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/app_bar/home_app_bar.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/fbp/fbp_device_screen_adaptor.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/bluetooth_scanner_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const double dragHandleSize = 30;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: HomeAppBar(
        themeData: themeData,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FbpDeviceScreenAdaptor(),
      ),
      body: Builder(
        builder: (context) {
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
    );
  }
}
