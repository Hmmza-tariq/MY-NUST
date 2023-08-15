import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';

class ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 30,
        child: IconButton(
          iconSize: 30,
          onPressed: func,
          icon: Icon(icon),
          color: icon == Icons.add ? AppTheme.darkGrey : Colors.white,
        ),
      ),
    );
  }
}
