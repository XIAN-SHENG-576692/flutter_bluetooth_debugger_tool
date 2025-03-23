import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/Infrastructure/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/utils/extra.dart';
import 'package:flutter_bluetooth_debugger_tool/service/data_stream/bluetooth_data_stream_manager.dart';
import 'package:provider/provider.dart';
import '../../change_notifier/bluetooth/bluetooth.dart';
import '../../utils/snackbar.dart';
import 'characteristic_tile.dart';
import 'descriptor_tile.dart';
import 'service_tile.dart';

class _DeviceProvider extends ChangeNotifier {
  final BluetoothDevice device;

  final TextEditingController mtuTextEditingController = TextEditingController();

  int? rssi;
  int? mtuSize;
  BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> get services => device.servicesList;
  bool isDiscoveringServices = false;
  bool isConnecting = false;
  bool isDisconnecting = false;

  late final StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late final StreamSubscription<bool> _isConnectingSubscription;
  late final StreamSubscription<bool> _isDisconnectingSubscription;
  late final StreamSubscription<int> _mtuSubscription;
  late final Timer _readRssiTimer;

  _DeviceProvider(this.device) {
    _connectionStateSubscription = device.connectionState.listen((state) async {
      connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        rssi = await device.readRssi();
      }
      notifyListeners();
    });

    _mtuSubscription = device.mtu.listen((value) {
      mtuSize = value;
      notifyListeners();
    });

    _isConnectingSubscription = device.isConnecting.listen((value) {
      isConnecting = value;
      notifyListeners();
    });

    _isDisconnectingSubscription = device.isDisconnecting.listen((value) {
      isDisconnecting = value;
      notifyListeners();
    });

    _readRssiTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) async {
        if(!device.isConnected) return;
        final newRssi = await device.readRssi();
        if(rssi == newRssi) return;
        rssi = newRssi;
        notifyListeners();
      },
    );
  }

  bool get isConnected => connectionState == BluetoothConnectionState.connected;

  Future<void> connect() async {
    await device.connectAndUpdateStream();
  }

  Future<void> cancelConnection() async {
    await device.disconnectAndUpdateStream(queue: false);
  }

  Future<void> disconnect() async {
    await device.disconnectAndUpdateStream();
  }

  Future<void> discoverServices(BluetoothDataStreamManagerImplFbp dataStreamManager) async {
    if(!device.isConnected) return;
    isDiscoveringServices = true;
    notifyListeners();
    try {
      final services = await device.discoverServices();
      dataStreamManager.registerTask(
        device: device,
        services: services,
      );
    } finally {
      isDiscoveringServices = false;
      notifyListeners();
    }
  }

  Future<void> requestMtu(int mtu) async {
    await device.requestMtu(mtu, predelay: 0);
  }

  void disposeStreams() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    mtuTextEditingController.dispose();
  }

  @override
  void dispose() {
    disposeStreams();
    _readRssiTimer.cancel();
    super.dispose();
  }
}

class DeviceDetailView extends StatelessWidget {
  const DeviceDetailView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final device = context.read<BluetoothDeviceDetailSelectorChangeNotifier>().bluetoothDevice;
    if(device == null) return Scaffold();
    return ChangeNotifierProvider(
      create: (_) => _DeviceProvider(device),
      builder: (context, _) {
        final device = context.read<_DeviceProvider>().device;
        return ScaffoldMessenger(
          key: Snackbar.snackBarKeyC,
          child: Scaffold(
            appBar: AppBar(
              title: Text(device.platformName),
              actions: const [ConnectButton()],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: const [
                  DeviceIdTile(),
                  ConnectionStatusTile(),
                  MtuSizeTile(),
                  ServicesList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<_DeviceProvider, (bool, bool, bool)>(
      selector: (_, provider) =>
      (provider.isConnecting, provider.isDisconnecting, provider.isConnected),
      builder: (_, state, __) {
        final isConnecting = state.$1;
        final isDisconnecting = state.$2;
        final isConnected = state.$3;
        final provider = context.read<_DeviceProvider>();

        return Row(
          children: [
            if (isConnecting || isDisconnecting)
              const Padding(
                padding: EdgeInsets.all(14.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black12,
                    color: Colors.black26,
                  ),
                ),
              ),
            TextButton(
              onPressed: isConnecting
                  ? provider.cancelConnection
                  : (isConnected ? provider.disconnect : provider.connect),
              child: Text(
                isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
                style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DeviceIdTile extends StatelessWidget {
  const DeviceIdTile({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteId = context.read<_DeviceProvider>().device.remoteId;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('$remoteId'),
    );
  }
}

class ConnectionStatusTile extends StatelessWidget {
  const ConnectionStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Selector<_DeviceProvider, bool>(
            selector: (_, p) => p.isConnected,
            builder: (_, isConnected, __) {
              return isConnected ? const Icon(Icons.bluetooth_connected) : const Icon(Icons.bluetooth_disabled);
            },
          ),
          Selector<_DeviceProvider, int?>(
            selector: (_, p) => p.rssi,
            builder: (_, rssi, __) {
              return Text(
                '${rssi?.toString()} dBm',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ],
      ),
      title: Selector<_DeviceProvider, BluetoothConnectionState>(
        selector: (_, p) => p.connectionState,
        builder: (_, state, __) {
          return Text(
            'Device is ${state.name}.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        },
      ),
      trailing: Selector<_DeviceProvider, bool>(
        selector: (_, p) => p.isDiscoveringServices,
        builder: (_, isDiscovering, __) {
          final provider = context.read<_DeviceProvider>();
          final taskProvider = context.read<BluetoothDataStreamManager>() as BluetoothDataStreamManagerImplFbp;
          return IndexedStack(
            index: isDiscovering ? 1 : 0,
            children: [
              TextButton(
                onPressed: () => provider.discoverServices(taskProvider),
                child: const Text("Get Services"),
              ),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MtuSizeTile extends StatelessWidget {
  const MtuSizeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<_DeviceProvider, int?>(
      selector: (_, p) => p.mtuSize,
      builder: (context, mtuSize, _) {
        final theme = Theme.of(context);
        final provider = context.read<_DeviceProvider>();
        return ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MTU Size',
                style: theme.textTheme.titleSmall,
              ),
              Text('${mtuSize ?? '-'} bytes'),
            ],
          ),
          title: TextField(
            controller: provider.mtuTextEditingController,
            keyboardType: TextInputType.numberWithOptions(),
            onSubmitted: (s) => provider.requestMtu(int.tryParse(s) ?? 0),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => provider.requestMtu(int.tryParse(provider.mtuTextEditingController.text) ?? 0),
          ),
        );
      },
    );
  }
}

class ServicesList extends StatelessWidget {
  const ServicesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<_DeviceProvider, List<BluetoothService>>(
      selector: (_, p) => p.services,
      builder: (_, services, __) {
        return Column(
          children: services
              .map((s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => CharacteristicTile(
              characteristic: c,
              descriptorTiles: c.descriptors
                  .map((d) => DescriptorTile(descriptor: d))
                  .toList(),
            ))
                .toList(),
          ))
              .toList(),
        );
      },
    );
  }
}
