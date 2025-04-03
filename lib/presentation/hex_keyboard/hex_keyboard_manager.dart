import 'package:flutter/widgets.dart';

import 'hex_keyboard_controller.dart';

class HexKeyboardManager extends ChangeNotifier {
  HexKeyboardController? _activeController;

  void setActive(HexKeyboardController controller) {
    _activeController = controller;
    notifyListeners();
  }

  void clearActive() {
    _activeController = null;
    notifyListeners();
  }

  HexKeyboardController? get active => _activeController;

  void insert(String key) => _activeController?.insert(key);
  void backspace() => _activeController?.backspace();
  void clear() => _activeController?.clear();
}
