import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_cxs_common_utils/basic/bytes.dart';
import 'package:flutter_cxs_common_utils/basic/string.dart';

import '../utils/snackbar.dart';

class DescriptorTile extends StatefulWidget {
  final BluetoothDescriptor descriptor;

  const DescriptorTile({super.key, required this.descriptor});

  @override
  State<DescriptorTile> createState() => _DescriptorTileState();
}

class _DescriptorTileState extends State<DescriptorTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  final TextEditingController writeValueTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.descriptor.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothDescriptor get d => widget.descriptor;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  Future onReadPressed() async {
    try {
      await d.read();
      Snackbar.show(ABC.c, "Descriptor Read : Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Descriptor Read Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  Future onWritePressed() async {
    try {
      await d.write(writeValueTextEditingController.text.hexToUint8List());
      Snackbar.show(ABC.c, "Descriptor Write : Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Descriptor Write Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  Widget buildWriteTextField(BuildContext context) {
    return TextField(
      controller: writeValueTextEditingController,
    );
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.descriptor.uuid.str.toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    if(_value.isEmpty) return Divider();
    final lists = Iterable.generate((
        _value.length / 10).ceil(),
          (index) {
        return _value.skip(index * 10).take(10).toList().asUint8List().toByteStrings();
      },
    ).indexed;
    return Column(
      children: [
        Divider(),
        Row(
          children: [
            Text(
              DateTime.now().toString(),
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey
              ),
            ),
          ],
        ),
        ...lists.map((e) {
          return Row(
            children: [
              Text(
                "${e.$1.toString().padLeft(2, '0')}. ",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey
                ),
              ),
              ...e.$2.indexed.map((s) => Text(
                s.$2,
                style: TextStyle(
                  fontSize: 13,
                  color: (s.$1 % 2 == 0) ? Colors.red : Colors.green,
                ),
              )),
            ],
          );
        }),
      ],
    );
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
      onPressed: onReadPressed,
      child: Text("Read"),
    );
  }

  Widget buildWriteButton(BuildContext context) {
    return TextButton(
      onPressed: onWritePressed,
      child: Text("Write"),
    );
  }

  Widget buildButtonRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildReadButton(context),
        buildWriteButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          buildUuid(context),
          buildValue(context),
          buildWriteTextField(context),
        ],
      ),
      subtitle: buildButtonRow(context),
    );
  }
}