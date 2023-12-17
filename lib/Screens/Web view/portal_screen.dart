import 'package:flutter/material.dart';
import 'webview.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key, required this.initialUrl});
  final String initialUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebsiteView(
          initialUrl: initialUrl,
        ),
      ),
    );
  }
}
