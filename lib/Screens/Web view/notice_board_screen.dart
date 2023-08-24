import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'webview.dart';
import '../../Provider/notice_board_provider.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String initialUrl = Provider.of<NoticeBoardProvider>(context).link;
    return Scaffold(
      body: SafeArea(
          child: WebsiteView(
        initialUrl: initialUrl,
      )),
    );
  }
}
