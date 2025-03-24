part of 'bluetooth.dart';

enum BluetoothScannerFilterOption {
  system,
  nameIsNotEmpty,
  isConnected,
  connectable,
}

class _Option {
  _Option(this.option);
  BluetoothScannerFilterOption option;
  bool isSelected = false;
}

class ScanResultBuffer {

  final VoidCallback _notifyListeners;
  final BluetoothDevice bluetoothDevice;

  late final Timer _readRssiTimer;
  int _rssi;
  int get rssi => _rssi;
  set rssi(int newRssi) {
    if(_rssi == newRssi) return;
    _rssi = newRssi;
    _notifyListeners();
  }

  final bool system;

  bool _connectable;
  bool get connectable => _connectable;
  set connectable(bool newConnectable) {
    if(_connectable == newConnectable) return;
    _connectable = newConnectable;
    _notifyListeners();
  }

  late final StreamSubscription _connectionStateSubscription;

  ScanResultBuffer({
    required this.bluetoothDevice,
    required int rssi,
    required this.system,
    required bool connectable,
    required VoidCallback notifyListeners,
  }) :
        _rssi = rssi,
        _connectable = connectable,
        _notifyListeners = notifyListeners
  {
    _readRssiTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) {
        if(!bluetoothDevice.isConnected) return;
        bluetoothDevice.readRssi().then((rssi) {
          if(_rssi == rssi) return;
          _rssi = rssi;
          _notifyListeners();
        });
      },
    );
    _connectionStateSubscription = bluetoothDevice
      .connectionState
      .listen((s) {
      _notifyListeners();
      });
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScanResultBuffer && runtimeType == other.runtimeType && bluetoothDevice == other.bluetoothDevice;
  void cancel() {
    _connectionStateSubscription.cancel();
    _readRssiTimer.cancel();
  }
}

class BluetoothScannerChangeNotifier extends ChangeNotifier {
  final UserPreferences userPreferences;
  BluetoothScannerChangeNotifier({
    required this.userPreferences,
  }) {
    _scanResultsSubscriptions = FlutterBluePlus.scanResults.listen((scanResults) {
      _scanResultsBuffer.addAll(scanResults
        .skip(_scanResultsBuffer.length)
        .map((r) => ScanResultBuffer(
          bluetoothDevice: r.device,
          rssi: r.rssi,
          system: false,
          connectable: r.advertisementData.connectable,
          notifyListeners: notifyListeners,
        ))
      );
      notifyListeners();
    });
    for(final option in BluetoothScannerFilterOption.values) {
      final o = _options.where((o) => o.option == option).first;
      userPreferences.getFilterOption(option).then((value) {
        if(value == null || o.isSelected == value) return;
        o.isSelected = !o.isSelected;
        notifyListeners();
      });
    }
  }
  final List<_Option> _options = List.generate(
    BluetoothScannerFilterOption.values.length,
    (index) {
      return _Option(BluetoothScannerFilterOption.values[index]);
    },
  );
  bool isSelectedFilterOption({
    required BluetoothScannerFilterOption option,
  }) {
    return _options.where((o) => o.option == option).first.isSelected;
  }
  void toggleFilterOption({
    required BluetoothScannerFilterOption option,
  }) {
    final o = _options.where((o) => o.option == option).first;
    o.isSelected = !o.isSelected;
    userPreferences.setFilterOption(option, o.isSelected);
    notifyListeners();
  }
  bool _filter(ScanResultBuffer buffer) {
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.system) && !buffer.system) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.nameIsNotEmpty) && buffer.bluetoothDevice.platformName.isEmpty) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.isConnected) && !buffer.bluetoothDevice.isConnected) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.connectable) && !buffer.connectable) return false;
    return true;
  }
  List<ScanResultBuffer> _scanResultsBuffer = [];
  Iterable<ScanResultBuffer> get filteredScanResultsBuffer => _scanResultsBuffer.where(_filter);
  late final StreamSubscription _scanResultsSubscriptions;

  Future refresh() async {
    if(FlutterBluePlus.isScanningNow) return;
    final devices = await FlutterBluePlus.systemDevices([]);
    final newBuffer = devices
      .map((d) {
        final b = _scanResultsBuffer.where((b) => b.bluetoothDevice == d).firstOrNull;
        return ScanResultBuffer(
          bluetoothDevice: d,
          rssi: b?.rssi ?? 0,
          system: true,
          connectable: b?.connectable ?? false,
          notifyListeners: notifyListeners,
        );
      }).toList();
    for(final b in _scanResultsBuffer) {
      b.cancel();
    }
    _scanResultsBuffer.clear();
    _scanResultsBuffer = newBuffer;
    return FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      continuousUpdates: true,
    );
  }
  @override
  void dispose() {
    for(final b in _scanResultsBuffer) {
      b.cancel();
    }
    _scanResultsBuffer.clear();
    super.dispose();
  }
}
