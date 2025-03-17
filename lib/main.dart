import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/init/initializer.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/bluetooth/bluetooth.dart' show BluetoothScannerChangeNotifier;
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/data_stream_task/data_stream_task.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/screen/home_screen.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:provider/provider.dart';

import 'Infrastructure/presentation/change_notifier/bluetooth/bluetooth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initializer = InitializerImpl();
  await initializer();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      color: themeData.screenBackgroundColor,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<BluetoothScannerChangeNotifier>(create: (_) => BluetoothScannerChangeNotifierImplFbp(bluetoothManager: bluetoothManager)),
          ChangeNotifierProvider<DataStreamTaskChangeNotifier>(create: (_) => DataStreamTaskChangeNotifier(dataStreamTask)),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}
