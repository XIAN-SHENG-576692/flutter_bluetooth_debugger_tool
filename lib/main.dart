import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/init/initializer.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/change_notifier/data_stream_task/data_stream_task.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/screen/home_screen.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart' show BluetoothDataStreamManager;
import 'package:flutter_bluetooth_debugger_tool/service/user_info/user_preferences.dart';
import 'package:provider/provider.dart';

import 'Infrastructure/service/user_info/user_preferences.dart';

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
          Provider<UserPreferences>(create: (_) => UserPreferencesImpl(
            sharedPreferences: sharedPreferences,
          )),
          Provider<BluetoothDataStreamManager>(create: (_) => bluetoothDataStreamManager),
          ChangeNotifierProvider<BluetoothTaskChangeNotifier>(create: (_) => BluetoothTaskChangeNotifier(bluetoothTask: bluetoothTask)),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}
