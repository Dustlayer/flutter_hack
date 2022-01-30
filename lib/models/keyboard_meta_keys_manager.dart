import 'package:flutter/material.dart';

class KeyboardMetaKeysManager extends ChangeNotifier {
  bool _isShiftPressed = false;

  bool get isShiftPressed => _isShiftPressed;
  set isShiftPressed(bool isPressed) {
    _isShiftPressed = isPressed;
    notifyListeners();
  }
}
