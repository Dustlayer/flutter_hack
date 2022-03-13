import 'package:auto_size_text/auto_size_text.dart';
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
          child: FittedBox(
            fit: BoxFit.fill,
            child: Icon(
              Icons.height_rounded,
              color: Theme.of(context).primaryColor,
            ),
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
  late final CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    _curvedAnimation.addListener(() {
      setState(() {});
    });
    super.initState();
  }

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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.yellow, Colors.grey],
              tileMode: TileMode.decal,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [_curvedAnimation.value, 0],
            ).createShader(bounds);
          },
          child: FittedBox(
            fit: BoxFit.fill,
            child: Icon(
              Icons.rotate_90_degrees_ccw,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}

class IndicatorContainer extends StatelessWidget {
  final String labelText;
  final Widget indicator;

  const IndicatorContainer({Key? key, required this.labelText, required this.indicator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: AutoSizeText(
              labelText,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 200),
            ),
          ),
        ),
        indicator,
      ],
    );
  }
}
