import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';
import 'package:provider/provider.dart';

import '../Core/theme_provider.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.errorName,
  });
  final String errorName;
  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Container(
      color: isLightMode ? Colors.white : Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorName.toUpperCase(),
            style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: AppTheme.fontName,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(
            child: Image.asset('assets/images/Error.png'),
          ),
        ],
      ),
    );
  }
}
