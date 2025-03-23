import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/detail/value_display.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cxs_common_utils/basic/string.dart';

import '../../utils/snackbar.dart';
import 'descriptor_tile.dart';

class CharacteristicController extends ChangeNotifier {
  final BluetoothCharacteristic characteristic;
  List<BluetoothDescriptor> get descriptors => characteristic.descriptors;
  ValueObject? value;
  final TextEditingController writeController = TextEditingController();
  late final StreamSubscription<List<int>> _valueSub;

  CharacteristicController(this.characteristic) {
    _valueSub = characteristic.lastValueStream.listen((v) {
      value = ValueObject(value: v);
      notifyListeners();
    });
  }

  Future<void> read() async {
    try {
      await characteristic.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e, s) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
      debugPrint("backtrace: $s");
    }
  }

  Future<void> write() async {
    try {
      await characteristic.write(
        writeController.text.hexToUint8List(),
        withoutResponse: characteristic.properties.writeWithoutResponse,
      );
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (characteristic.properties.read) await characteristic.read();
    } catch (e, s) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
      debugPrint("backtrace: $s");
    }
  }

  Future<void> toggleNotify() async {
    try {
      final op = characteristic.isNotifying ? "Unsubscribe" : "Subscribe";
      await characteristic.setNotifyValue(!characteristic.isNotifying);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (characteristic.properties.read) await characteristic.read();
      notifyListeners();
    } catch (e, s) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
      debugPrint("backtrace: $s");
    }
  }

  bool get canRead => characteristic.properties.read;
  bool get canWrite => characteristic.properties.write || characteristic.properties.writeWithoutResponse;
  bool get canNotify => characteristic.properties.notify || characteristic.properties.indicate;
  bool get isNotifying => characteristic.isNotifying;

  String get uuidText => '0x${characteristic.uuid.str.toUpperCase()}';

  @override
  void dispose() {
    _valueSub.cancel();
    writeController.dispose();
    super.dispose();
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({
    super.key,
    required this.characteristic,
    required this.descriptorTiles,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacteristicController(characteristic),
      child: const _CharacteristicView(),
    );
  }
}

class _CharacteristicView extends StatelessWidget {
  const _CharacteristicView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CharacteristicController>();
    final isNotifying = context.select<CharacteristicController, bool>((c) => c.isNotifying);

    return ExpansionTile(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Characteristic'),
            Text(controller.uuidText, style: const TextStyle(fontSize: 13)),
            Divider(),
            _ValueDisplay(),
            if (controller.canWrite) _WriteField(),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.canRead)
              TextButton(onPressed: controller.read, child: const Text("Read")),
            if (controller.canWrite)
              TextButton(
                onPressed: controller.write,
                child: Text(controller.characteristic.properties.writeWithoutResponse
                    ? "WriteNoResp"
                    : "Write"),
              ),
            if (controller.canNotify)
              TextButton(
                onPressed: controller.toggleNotify,
                child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
              ),
          ],
        ),
      ),
      children: controller.descriptors
        .map((descriptor) => DescriptorTile(descriptor: descriptor))
        .toList(),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<CharacteristicController, ValueObject?>((c) => c.value);
    return (value != null) ? ValueDisplay(value: value) : Column();
  }
}

class _WriteField extends StatelessWidget {
  const _WriteField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CharacteristicController>().writeController;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Enter HEX to Write'),
        maxLines: 1,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
