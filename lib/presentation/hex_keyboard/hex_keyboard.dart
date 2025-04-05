import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_debugger_tool/presentation/theme/theme_data.dart';
import 'hex_keyboard_manager.dart';

class HexKeyboard extends StatelessWidget {
  final HexKeyboardManager manager;
  const HexKeyboard({super.key, required this.manager});

  static const _repeatDelay = Duration(milliseconds: 500);
  static const _repeatRate = Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> rows = [
      _buildRow(['0', '1', '2', '3'], icon: Icons.backspace, repeat: true, onIconPressed: manager.backspace),
      _buildRow(['4', '5', '6', '7'], icon: Icons.clear, onIconPressed: manager.clear),
      _buildRow(['8', '9', 'A', 'B'], spacer: true),
      _buildRow(['C', 'D', 'E', 'F'], spacer: true),
    ];

    final theme = Theme.of(context);
    return Container(
      color: theme.hexKeyboardBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.map((children) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children.map((child) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: child,
              ),
            )).toList(),
          ),
        )).toList(),
      ),
    );
  }

  List<Widget> _buildRow(List<String> keys,
      {IconData? icon, VoidCallback? onIconPressed, bool spacer = false, bool repeat = false}) {
    final buttons = keys.map<Widget>((k) => ElevatedButton(
      onPressed: () => manager.insert(k),
      child: Text(k),
    )).toList();

    if (icon != null && onIconPressed != null) {
      buttons.add(_buildIconKey(icon, onIconPressed, repeat));
    } else if (spacer) {
      buttons.add(const SizedBox.shrink());
    }

    return buttons;
  }

  Widget _buildIconKey(IconData icon, VoidCallback onPressed, bool repeat) {
    if (!repeat) {
      return ElevatedButton(onPressed: onPressed, child: Icon(icon));
    }

    return _RepeatableButton(icon: icon, onRepeatPressed: onPressed);
  }
}

class _RepeatableButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onRepeatPressed;

  const _RepeatableButton({required this.icon, required this.onRepeatPressed});

  @override
  State<_RepeatableButton> createState() => _RepeatableButtonState();
}

class _RepeatableButtonState extends State<_RepeatableButton> {
  Timer? _timer;

  void _startRepeat() {
    widget.onRepeatPressed();
    _timer = Timer(HexKeyboard._repeatDelay, () {
      _timer = Timer.periodic(HexKeyboard._repeatRate, (_) => widget.onRepeatPressed());
    });
  }

  void _stopRepeat() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => _startRepeat(),
      onPanEnd: (_) => _stopRepeat(),
      onPanCancel: () => _stopRepeat(),
      child: ElevatedButton(
        onPressed: () {}, // Disabled to force GestureDetector to control
        child: Icon(widget.icon),
      ),
    );
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }
}
