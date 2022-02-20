import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardMetaKeysManager extends ChangeNotifier {
  bool _isShiftPressed = false;
  bool _isAltPressed = false;

  bool get isShiftPressed => _isShiftPressed;
  set isShiftPressed(bool isPressed) {
    _isShiftPressed = isPressed;
    notifyListeners();
  }

  bool get isAltPressed => _isAltPressed;
  set isAltPressed(bool isPressed) {
    _isAltPressed = isPressed;
    notifyListeners();
  }

  void setWithEvent(RawKeyEvent event) {
    // there is a bug with handling shift and alt at the same time, so falling back to "normal" keys
    /*_isShiftPressed = event.isShiftPressed;
    _isAltPressed = event.isAltPressed;*/
    _isShiftPressed = event.isKeyPressed(LogicalKeyboardKey.keyA);
    _isAltPressed = event.isKeyPressed(LogicalKeyboardKey.keyS);
    notifyListeners();
  }
}
