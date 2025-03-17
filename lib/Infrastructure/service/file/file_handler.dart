import 'package:flutter_bluetooth_debugger_tool/init/initializer.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/data_stream.dart';
import 'package:flutter_bluetooth_debugger_tool/service/file/file_handler.dart';
import 'package:flutter_cxs_file_utils/csv/simple_csv_file.dart';
import 'package:flutter_cxs_common_utils/flutter_cxs_common_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:synchronized/synchronized.dart';

part 'bluetooth_packet_file.dart';

class FileHandlerImpl extends FileHandler {
  @override
  Future<BluetoothPacketFile> createBluetoothPacket() {
    return BluetoothPacketFileImpl.create();
  }
}
