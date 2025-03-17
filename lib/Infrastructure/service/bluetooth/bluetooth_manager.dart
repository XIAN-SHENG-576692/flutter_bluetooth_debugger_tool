part of 'bluetooth.dart';

class BluetoothManagerImplFbp extends CustomBluetoothDeviceTracker<BluetoothDeviceImplFbp> with CustomBluetoothDeviceTrackerRssi implements BluetoothManager {
  BluetoothManagerImplFbp({
    required super.devices,
  }) : super(
    deviceCreator: (device) => BluetoothDeviceImplFbp(bluetoothDevice: device),
  );

  Future<bool> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.location,
    ].request();
    for(final state in statuses.values) {
      if(state != PermissionStatus.granted) return false;
    }
    return true;
  }

  @override
  Future startScan() {
    return FlutterBluePlusUtils.startScan(
      requestPermission: requestPermission,
      scanDuration: const Duration(seconds: 15),
    );
  }

  @override
  Future rescan() {
    return FlutterBluePlusUtils.rescan(
      requestPermission: requestPermission,
      scanDuration: const Duration(seconds: 15),
    );
  }

  @override
  Future toggleScan() {
    return FlutterBluePlusUtils.toggleScan(
      requestPermission: requestPermission,
      scanDuration: const Duration(seconds: 15),
    );
  }

  @override
  Future turnOn() {
    return FlutterBluePlusUtils.turnOn(requestPermission: requestPermission);
  }

  @override
  bool get isOn => FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;

  @override
  bool get isScanning => FlutterBluePlus.isScanningNow;

}
