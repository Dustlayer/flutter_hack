import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class BackWidget extends StatelessWidget {
  const BackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      hoverColor: Colors.deepPurple.withOpacity(0.15),
      onTap: () => Beamer.of(context).canBeamBack ? Beamer.of(context).beamBack() : Navigator.of(context).maybePop(),
      child: const Padding(
        padding: EdgeInsets.all(3),
        child: Icon(
          Icons.arrow_back,
          color: Colors.green,
        ),
      ),
    );
  }
}
