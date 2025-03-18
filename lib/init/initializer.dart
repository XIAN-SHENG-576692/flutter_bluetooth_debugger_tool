import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/bluetooth/bluetooth.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/data_stream/data_stream.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/file/file_handler.dart';
import 'package:flutter_bluetooth_debugger_tool/application/data_stream_task.dart';
import 'package:flutter_bluetooth_debugger_tool/init/timer.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/data_stream.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:path_provider_cxs_utils/path_provider_cxs_utils.dart';

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
    bluetoothManager = BluetoothManagerImplFbp(
      devices: (await FlutterBluePlus.systemDevices([])),
    );
    fileHandler = FileHandlerImpl();
    dataStream = DataStreamImplFbp(
      abstractBluetoothDeviceTracker: bluetoothManager,
    );

    readRssi = bluetoothManager.readRssi(duration: const Duration(milliseconds: 100));

    dataStreamTask = DataStreamTask(
      dataStream: dataStream,
      fileHandler: fileHandler,
    );
  }
}
