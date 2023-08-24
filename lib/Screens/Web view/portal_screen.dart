import 'dart:async';

import 'package:flutter/material.dart';
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
  bool showCopyButton = true;
  bool forwardAnimation = true;
  Timer? _timer;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          animationController!.repeat();
          forwardAnimation = false;
          _timer = Timer(const Duration(milliseconds: 700), () {
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
    _timer!.cancel();
    super.dispose();
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
          Padding(
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
                            child: const ClipboardWidget(),
                          ),
                        )
                      : Visibility(
                          visible: showCopyButton,
                          child: ScaleTransition(
                            alignment: Alignment.centerLeft,
                            scale: scaleAnimation,
                            child: const ClipboardWidget(),
                          ),
                        );
                }),
          )
        ],
      )),
    );
  }
}
