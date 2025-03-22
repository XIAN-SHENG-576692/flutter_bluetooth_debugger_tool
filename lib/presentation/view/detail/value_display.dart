import 'package:flutter/material.dart';
import 'package:flutter_cxs_common_utils/basic/bytes.dart';

class ValueDisplay extends StatelessWidget {
  final List<int> value;
  const ValueDisplay({
    super.key,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const Column();
    final lines = Iterable.generate((value.length / 10).ceil(), (i) {
      return value.skip(i * 10).take(10).toList().asUint8List().toByteStrings();
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          DateTime.now().toString(),
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        ...lines.indexed.map((line) {
          return Row(
            children: [
              Text(
                "${line.$1.toString().padLeft(2, '0')}. ",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              ...line.$2.indexed.map((b) => Text(
                b.$2,
                style: TextStyle(
                  fontSize: 13,
                  color: (b.$1 % 2 == 0) ? Colors.red : Colors.green,
                ),
              )),
            ],
          );
        }),
      ],
    );
  }
}
