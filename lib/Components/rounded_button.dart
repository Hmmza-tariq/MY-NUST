import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';

class RoundedButton extends StatefulWidget {
  final String title;
  final Function onPressed;
  final IconData icon;
  final double fontSize;
  final double iconSize;

  const RoundedButton({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.icon,
    this.fontSize = 18,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  RoundedButtonState createState() => RoundedButtonState();
}

class RoundedButtonState extends State<RoundedButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Material(
        elevation: 2,
        color: themeProvider.primaryColor,
        borderRadius: BorderRadius.circular(20.0),
        borderOnForeground: true,
        child: InkWell(
          onTap: () => widget.onPressed(),
          onHover: (value) {
            setState(() {
              isHovered = value;
            });
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: 80.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                Transform.scale(
                  scale: isHovered ? 5 : 1.0,
                  child: Icon(widget.icon,
                      color: Colors.white, size: widget.iconSize),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style:
                      TextStyle(color: Colors.white, fontSize: widget.fontSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
