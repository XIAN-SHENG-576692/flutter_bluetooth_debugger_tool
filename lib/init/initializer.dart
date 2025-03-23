import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/file/file_handler.dart';
import 'package:flutter_bluetooth_debugger_tool/application/bluetooth_task.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:path_provider_cxs_utils/path_provider_cxs_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'application.dart';
part 'path.dart';
part 'service.dart';

abstract class Initializer {
  Future<void> call();
}

class InitializerImpl extends Initializer {
  @override
  Future<void> call() async {
    filePath = (await getSystemDownloadDirectory())?.absolute.path ?? "";

    FlutterBluePlus.setLogLevel(LogLevel.none);
    fileHandler = FileHandlerImpl();
    sharedPreferences = await SharedPreferences.getInstance();

    bluetoothDataStreamManager = BluetoothDataStreamManagerImplFbp();

    bluetoothTask = BluetoothTask(
      bluetoothDataStreamManager: bluetoothDataStreamManager,
      fileHandler: fileHandler,
    );
  }
}
