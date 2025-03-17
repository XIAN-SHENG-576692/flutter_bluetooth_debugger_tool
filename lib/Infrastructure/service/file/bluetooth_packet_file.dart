part of 'file_handler.dart';

class BluetoothPacketFileImpl extends BluetoothPacketFile {
  final Lock _lock = Lock();
  final SimpleCsvFile _file;
  static Future<BluetoothPacketFile> create() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    final file = BluetoothPacketFileImpl._(
      filePath: filePath,
      fileName: "${appName}_${DateTime.now().toFileFormat()}",
    );
    return file._lock.synchronized(() async {
      try {
        await file._file.clear(bom: false);
        await file._file.writeAsString(
          data: [
            "Device id",
            "Device name",
            "Layer",
            "Layer UUID",
            "Time",
            "Data",
          ],
        );
        return file;
      } catch(e) {
        return file;
      }
    });
  }
  BluetoothPacketFileImpl._({
    required String filePath,
    required String fileName,
  }) : _file = SimpleCsvFile(path: '$filePath/$fileName.csv');
  @override
  Future<bool> write(BluetoothPacket packet) {
    return _lock.synchronized(() async {
      try {
        await _file.writeAsString(
          data: [
            packet.deviceId,
            packet.deviceName,
            packet.layer.name,
            packet.layerUuid,
            packet.dateTime.toString(),
            ...packet.byteBuffer.asUint8List().toByteStrings(),
          ],
        );
        return true;
      } catch(e) {
        return false;
      }
    });
  }
}
