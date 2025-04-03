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
      readOnly: true,
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        manager.setActive(controller);
      },
      showCursor: true,
      decoration: const InputDecoration(
        hintText: 'Hex Input',
        // border: OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}
