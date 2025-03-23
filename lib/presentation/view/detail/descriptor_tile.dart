import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/view/detail/value_display.dart';
import 'package:flutter_cxs_common_utils/basic/string.dart';
import 'package:provider/provider.dart';

import '../../utils/snackbar.dart';

class DescriptorController extends ChangeNotifier {
  final BluetoothDescriptor descriptor;
  final TextEditingController writeController = TextEditingController();
  ValueObject? value;
  late final StreamSubscription<List<int>> _valueSub;

  DescriptorController(this.descriptor) {
    _valueSub = descriptor.lastValueStream.listen((v) {
      value = ValueObject(value: v);
      notifyListeners();
    });
  }

  String get uuid => '0x${descriptor.uuid.str.toUpperCase()}';

  Future<void> read() async {
    try {
      await descriptor.read();
      Snackbar.show(ABC.c, "Descriptor Read : Success", success: true);
    } catch (e, s) {
      Snackbar.show(ABC.c, prettyException("Descriptor Read Error:", e), success: false);
      debugPrint("backtrace: $s");
    }
  }

  Future<void> write() async {
    try {
      await descriptor.write(writeController.text.hexToUint8List());
      Snackbar.show(ABC.c, "Descriptor Write : Success", success: true);
    } catch (e, s) {
      Snackbar.show(ABC.c, prettyException("Descriptor Write Error:", e), success: false);
      debugPrint("backtrace: $s");
    }
  }

  @override
  void dispose() {
    _valueSub.cancel();
    writeController.dispose();
    super.dispose();
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;

  const DescriptorTile({super.key, required this.descriptor});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DescriptorController(descriptor),
      child: const _DescriptorView(),
    );
  }
}

class _DescriptorView extends StatelessWidget {
  const _DescriptorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DescriptorController>();

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Descriptor'),
          Text(controller.uuid, style: const TextStyle(fontSize: 13)),
          const Divider(),
          const _ValueSection(),
          const SizedBox(height: 8),
          TextField(
            controller: controller.writeController,
            decoration: const InputDecoration(hintText: 'Enter HEX to Write'),
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: controller.read, child: const Text("Read")),
          TextButton(onPressed: controller.write, child: const Text("Write")),
        ],
      ),
    );
  }
}

class _ValueSection extends StatelessWidget {
  const _ValueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<DescriptorController, ValueObject?>((c) => c.value);
    return (value != null) ? ValueDisplay(value: value) : Column();
  }
}
