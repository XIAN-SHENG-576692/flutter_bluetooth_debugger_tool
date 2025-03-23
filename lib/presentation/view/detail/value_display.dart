import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cxs_common_utils/basic/bytes.dart';

class ValueObject extends Equatable {
  DateTime time = DateTime.now();
  final List<int> value;
  ValueObject({
    required this.value,
  });
  @override
  List<Object?> get props => [
    time,
    value,
  ];
}

class ValueDisplay extends StatelessWidget {
  final ValueObject value;
  const ValueDisplay({
    super.key,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    final lines = Iterable.generate((value.value.length / 10).ceil(), (i) {
      return value.value.skip(i * 10).take(10).toList().asUint8List().toByteStrings();
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          value.time.toString(),
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
