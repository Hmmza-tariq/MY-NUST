import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/clipboard_widget.dart';
import 'webview.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key, required this.initialUrl});
  final String initialUrl;

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  bool showCopyButton = true,
      forwardAnimation = true,
      copyButtonEnabled = false,
      isLMS = false;
  int time = 50;
  @override
  void initState() {
    if (widget.initialUrl.contains("lms.nust.edu.pk")) {
      isLMS = true;
    }
    _loadCopyPreference().then((value) {
      setState(() {
        copyButtonEnabled = value ?? false;
      });
    });
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    Timer(Duration(seconds: time), () {
      if (mounted) {
        setState(() {
          animationController!.repeat();
          forwardAnimation = false;
          Timer(const Duration(milliseconds: 700), () {
            if (mounted) {
              setState(() {
                animationController!.stop();
                showCopyButton = false;
              });
            }
          });
        });
      }
    });

    animationController!.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    // _timer!.cancel();
    super.dispose();
  }

  Future<bool?> _loadCopyPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('copyButton');
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    Animation<double> scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0, 1, curve: Curves.bounceOut),
      ),
    );

    return Scaffold(
      body: SafeArea(
          child: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          WebsiteView(
            initialUrl: widget.initialUrl,
          ),
          copyButtonEnabled
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 5,
                  ),
                  child: AnimatedBuilder(
                      animation: animationController!,
                      builder: (BuildContext context, Widget? child) {
                        return forwardAnimation
                            ? FadeTransition(
                                opacity: fadeAnimation,
                                child: Transform(
                                  transform: Matrix4.translationValues(
                                    -50 * (1.0 - fadeAnimation.value),
                                    0,
                                    0,
                                  ),
                                  child: ClipboardWidget(
                                    isLMS: isLMS,
                                  ),
                                ),
                              )
                            : Visibility(
                                visible: showCopyButton,
                                child: ScaleTransition(
                                  alignment: Alignment.centerLeft,
                                  scale: scaleAnimation,
                                  child: ClipboardWidget(
                                    isLMS: isLMS,
                                  ),
                                ),
                              );
                      }),
                )
              : Container()
        ],
      )),
    );
  }
}
