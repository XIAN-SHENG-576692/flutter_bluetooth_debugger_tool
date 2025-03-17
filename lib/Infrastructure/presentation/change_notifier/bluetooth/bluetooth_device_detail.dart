part of 'bluetooth.dart';

class BluetoothDeviceDetailStatusImplFbp implements BluetoothDeviceDetailStatus {
  BluetoothDevice bluetoothDevice;
  BluetoothDeviceDetailStatusImplFbp({required this.bluetoothDevice});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is BluetoothDeviceDetailStatusImplFbp && runtimeType == other.runtimeType && bluetoothDevice == other.bluetoothDevice);
}
