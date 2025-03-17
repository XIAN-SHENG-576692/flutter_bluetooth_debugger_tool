part of 'bluetooth.dart';

class _Option {
  _Option(this.option);
  BluetoothScannerFilterOption option;
  bool isSelected = false;
}

class BluetoothScannerChangeNotifierImplFbp extends CustomBluetoothDeviceLengthTrackerChangeNotifier<BluetoothDeviceImplFbp>
    with CustomBluetoothDeviceRssiTrackerChangeNotifier,
    CustomBluetoothDeviceConnectableTrackerChangeNotifier,
    CustomBluetoothDeviceConnectionStateTrackerChangeNotifier,
    CustomBluetoothDeviceScanTrackerChangeNotifier,
    BluetoothIsScanningChangeNotifier,
    BluetoothAdapterStateChangeNotifier,
    BluetoothIsOnChangeNotifier
    implements BluetoothScannerChangeNotifier 
{
  BluetoothManagerImplFbp bluetoothManager;

  final List<_Option> _options = List.generate(
    BluetoothScannerFilterOption.values.length,
    (index) {
      return _Option(BluetoothScannerFilterOption.values[index]);
    },
  );

  BluetoothScannerChangeNotifierImplFbp({
    required this.bluetoothManager,
  }) : super(
    tracker: bluetoothManager,
  );

  @override
  Iterable<BluetoothDeviceStatusImplFbp> get filteredDevices => bluetoothManager
      .devices
      .where(deviceFilter)
      .map((d) => BluetoothDeviceStatusImplFbp(
        scannerChangeNotifierImplFbp: this,
        bluetoothDevice: d,
      ));

  @override
  bool isSelectedFilterOption({
    required BluetoothScannerFilterOption option,
  }) {
    return _options.where((o) => o.option == option).first.isSelected;
  }
  @override
  void toggleFilterOption({
    required BluetoothScannerFilterOption option,
  }) {
    final o = _options.where((o) => o.option == option).first;
    o.isSelected = !o.isSelected;
    notifyListeners();
  }
  bool deviceFilter(BluetoothDevice device) {
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.isScanned) && !device.isScanned) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.isConnected) && !device.isConnected) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.connectable) && !device.connectable) return false;
    if(isSelectedFilterOption(option: BluetoothScannerFilterOption.nameIsNotEmpty) && device.deviceName.isEmpty) return false;
    return true;
  }

  @override
  bool get isOn => bluetoothManager.isOn;
  @override
  Future turnOn() {
    return bluetoothManager.turnOn();
  }

  @override
  bool get isScanning => bluetoothManager.isScanning;
  @override
  Future startScan() {
    return bluetoothManager.startScan();
  }
  @override
  Future rescan() {
    return bluetoothManager.rescan();
  }
  @override
  Future toggleScan() {
    return bluetoothManager.toggleScan();
  }

  BluetoothDeviceDetailStatusImplFbp? _selectedDevice;
  @override
  BluetoothDeviceDetailStatusImplFbp? get selectedDevice => _selectedDevice;
  setSelectedDevice(BluetoothDevice? device) {
    if(device == _selectedDevice?.bluetoothDevice) return;
    _selectedDevice = (device != null) ? BluetoothDeviceDetailStatusImplFbp(bluetoothDevice: device) : null;
    notifyListeners();
  }
}
