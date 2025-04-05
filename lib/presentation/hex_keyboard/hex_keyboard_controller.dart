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
}
