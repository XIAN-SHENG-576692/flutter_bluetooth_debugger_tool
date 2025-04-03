import 'package:flutter/material.dart';

import 'hex_keyboard_manager.dart';

class HexKeyboard extends StatelessWidget {
  final HexKeyboardManager manager;
  final VoidCallback? onClose;

  const HexKeyboard({
    super.key,
    required this.manager,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final keys = '0123456789ABCDEF'.split('');
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in keys)
                  ElevatedButton(
                    onPressed: () => manager.insert(k),
                    child: Text(k),
                  ),
                ElevatedButton(
                  onPressed: manager.backspace,
                  child: const Icon(Icons.backspace),
                ),
                ElevatedButton(
                  onPressed: manager.clear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
