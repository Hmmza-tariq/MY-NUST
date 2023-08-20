import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({
    super.key,
    required this.errorName,
  });
  final String errorName;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    // Provider.of<InternetProvider>(context).isConnected ? Navigator.pop(context) : null;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.errorName.toUpperCase(),
            style: const TextStyle(
              decoration: TextDecoration.none,
              fontFamily: AppTheme.fontName,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
