import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hex_keyboard_controller.dart';
import 'hex_keyboard_manager.dart';

class HexKeyboardInputField extends StatelessWidget {
  final HexKeyboardController controller;
  final HexKeyboardManager manager;

  const HexKeyboardInputField({
    super.key,
    required this.controller,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.textController,
      readOnly: false,
      keyboardType: TextInputType.none,
      showCursor: true,
      enableInteractiveSelection: true,
      inputFormatters: [
        _UpperCaseHexFormatter(),
      ],
      onTap: () {
        manager.setActive(controller);
      },
      decoration: const InputDecoration(
        hintText: 'Hex Input',
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}

class _UpperCaseHexFormatter extends TextInputFormatter {
  final RegExp _hexRegex = RegExp(r'[0-9a-fA-F]');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final filtered = newValue.text
        .split('')
        .where((char) => _hexRegex.hasMatch(char))
        .join()
        .toUpperCase();

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
