import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/app_bar/home_app_bar.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/hex_keyboard/hex_keyboard.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/hex_keyboard/hex_keyboard_controller.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/hex_keyboard/hex_keyboard_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/scanner/bluetooth_scanner_view.dart';
import 'package:provider/provider.dart';

import '../../service/user_info/user_preferences.dart';
import '../change_notifier/bluetooth/bluetooth.dart';
import '../view/detail/device_detail_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const double dragHandleSize = 30;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final active = context.select<HexKeyboardManager, HexKeyboardController?>((manager) => manager.active);
    final manager = context.read<HexKeyboardManager>();
    return PopScope(
      canPop: active == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && (active != null)) {
          manager.clearActive();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => BluetoothDeviceDetailSelectorChangeNotifier(
                    openDeviceDetailView: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                ChangeNotifierProvider<BluetoothScannerChangeNotifier>(create: (context) => BluetoothScannerChangeNotifier(
                  userPreferences: context.read<UserPreferences>(),
                )),
                ChangeNotifierProvider<BluetoothDeviceDetailSelectorChangeNotifier>(create: (_) => BluetoothDeviceDetailSelectorChangeNotifier()),
              ],
              child: Scaffold(
                appBar: HomeAppBar(
                  themeData: themeData,
                ),
                drawer: Drawer(
                  width: MediaQuery.of(context).size.width * 0.80,
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
            ),
          ),
          (active == null)
            ? Row()
            : HexKeyboard(
              manager: manager,
            ),
        ],
      ),
    );
  }
}
