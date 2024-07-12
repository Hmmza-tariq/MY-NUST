import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.func,
    required this.icon,
    required this.color,
  });
  final Function() func;
  final IconData icon;
  final Color color;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  void initState() {
    if (widget.icon == Icons.calculate) {
      // ResultAd.loadAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FloatingActionButton(
          heroTag: null,
          backgroundColor: widget.color,
          onPressed: () {
            widget.func();
          },
          child: Icon(
            widget.icon,
            size: 30,
            color: widget.icon == Icons.add ? AppTheme.darkGrey : Colors.white,
          )),
    );
  }
}
