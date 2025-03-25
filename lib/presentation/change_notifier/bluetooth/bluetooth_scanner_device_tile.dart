part of 'bluetooth.dart';

class BluetoothScannerDeviceTileChangeNotifier extends ChangeNotifier {
  final BluetoothScannerChangeNotifier scanner;
  final int index;
  ScanResultBuffer get buffer => scanner.filteredScanResultsBuffer.elementAt(index);
  BluetoothScannerDeviceTileChangeNotifier({
    required this.scanner,
    required this.index,
  }) {
    scanner.addListener(notifyListeners);
  }
  @override
  void dispose() {
    scanner.removeListener(notifyListeners);
    super.dispose();
  }
}
