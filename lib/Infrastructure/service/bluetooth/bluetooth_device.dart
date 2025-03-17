part of 'bluetooth.dart';

class BluetoothDeviceImplFbp extends CustomBluetoothDevice with
    CustomBluetoothDeviceConnectable,
    CustomBluetoothDeviceDiscover,
    CustomBluetoothDeviceRssi,
    CustomBluetoothDeviceScan
    implements BluetoothDevice
{
  BluetoothDeviceImplFbp({
    required super.bluetoothDevice,
  });

  @override
  bool get isConnected => bluetoothDevice.isConnected;

  @override
  int get mtu => bluetoothDevice.mtuNow;

  @override
  Stream<int> get mtuStream => bluetoothDevice.mtu;

  @override
  Future<int> requestMtu(int mtu) {
    return bluetoothDevice.requestMtu(mtu);
  }

  @override
  Future<bool> toggleConnection() {
    return BluetoothDeviceUtils.toggleConnection(
      device: bluetoothDevice,
    );
  }

}
