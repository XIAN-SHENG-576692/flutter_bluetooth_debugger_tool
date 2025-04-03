import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HexKeyboardController extends ChangeNotifier {
  late TextEditingController textController;
  late FocusNode focusNode;
  void Function(String)? onChanged;

  HexKeyboardController({String? initialValue, this.onChanged}) {
    textController = TextEditingController(text: initialValue ?? '');
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(Duration.zero, () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
      }
    });
    textController.addListener(() {
      onChanged?.call(textController.text.toUpperCase());
    });
  }

  String get text => textController.text;

  set text(String value) {
    textController.text = value.toUpperCase();
    _moveCursorToEnd();
    notifyListeners();
    onChanged?.call(textController.text);
  }

  void clear() {
    textController.clear();
    notifyListeners();
    onChanged?.call(textController.text);
  }

  void backspace() {
    final value = textController.value;
    final sel = value.selection;
    if (sel.start == 0 && sel.end == 0) return;

    final newText = value.text.replaceRange(
      sel.isCollapsed ? sel.start - 1 : sel.start,
      sel.end,
      '',
    );

    final newOffset = sel.isCollapsed ? sel.start - 1 : sel.start;

    textController.value = TextEditingValue(
      text: newText.toUpperCase(),
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, newText.length),
      ),
    );

    notifyListeners();
    onChanged?.call(textController.text);
  }

  void insert(String hexChar) {
    final value = textController.value;
    final sel = value.selection;

    final newText = value.text.replaceRange(sel.start, sel.end, hexChar);

    final newOffset = sel.start + hexChar.length;

    textController.value = TextEditingValue(
      text: newText.toUpperCase(),
      selection: TextSelection.collapsed(offset: newOffset),
    );

    notifyListeners();
    onChanged?.call(textController.text);
  }

  void setCursor(int offset) {
    final length = textController.text.length;
    final safeOffset = offset.clamp(0, length);
    textController.selection = TextSelection.collapsed(offset: safeOffset);
  }

  void _moveCursorToEnd() {
    final len = textController.text.length;
    textController.selection = TextSelection.collapsed(offset: len);
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  OverlayEntry? _overlayEntry;

  void showKeyboardOverlay(BuildContext context) {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          elevation: 10,
          child: _HexKeyboardOverlay(controller: this),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void hideKeyboardOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

}

class _HexKeyboardOverlay extends StatelessWidget {
  final HexKeyboardController controller;

  const _HexKeyboardOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HexKeys(controller: controller),
            TextButton.icon(
              onPressed: controller.hideKeyboardOverlay,
              icon: const Icon(Icons.keyboard_hide),
              label: const Text("Hide"),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared keyboard button area
class _HexKeys extends StatelessWidget {
  final HexKeyboardController controller;

  const _HexKeys({required this.controller});

  @override
  Widget build(BuildContext context) {
    final keys = '0123456789ABCDEF'.split('');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final k in keys)
          ElevatedButton(
            onPressed: () => controller.insert(k),
            child: Text(k),
          ),
        ElevatedButton(
          onPressed: controller.backspace,
          child: const Icon(Icons.backspace),
        ),
        ElevatedButton(
          onPressed: controller.clear,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
