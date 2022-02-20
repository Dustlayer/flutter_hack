import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/keyboard_meta_keys_manager.dart';

class ShiftIndicator extends StatefulWidget {
  const ShiftIndicator({Key? key}) : super(key: key);

  @override
  _ShiftIndicatorState createState() => _ShiftIndicatorState();
}

class _ShiftIndicatorState extends State<ShiftIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KeyboardMetaKeysManager>(
      builder: (context, manager, _) {
        if (manager.isShiftPressed) {
          _controller.forward();
        } else {
          _controller.animateBack(0.0);
        }
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 0.25).animate(_controller),
          child: const FittedBox(
            fit: BoxFit.fill,
            child: Icon(Icons.height_rounded),
          ),
        );
      },
    );
  }
}

class AltIndicator extends StatefulWidget {
  const AltIndicator({Key? key}) : super(key: key);

  @override
  _AltIndicatorState createState() => _AltIndicatorState();
}

class _AltIndicatorState extends State<AltIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KeyboardMetaKeysManager>(
      builder: (context, manager, _) {
        if (manager.isAltPressed) {
          _controller.forward();
        } else {
          _controller.animateBack(0.0);
        }
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 0.25).animate(_controller),
          child: const FittedBox(
            fit: BoxFit.fill,
            child: Icon(Icons.height_rounded),
          ),
        );
      },
    );
  }
}
