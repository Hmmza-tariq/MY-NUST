import 'dart:async';

import 'package:flutter/material.dart';
import '../../Components/clipboard_widget.dart';
import '../../Components/webview.dart';

class LmsScreen extends StatefulWidget {
  const LmsScreen({super.key});

  @override
  State<LmsScreen> createState() => _LmsScreenState();
}

class _LmsScreenState extends State<LmsScreen> with TickerProviderStateMixin {
  var initialUrl =
      'https://lms.nust.edu.pk/portal/calendar/view.php?view=month';
  AnimationController? animationController;
  bool showCopyButton = true;
  bool forwardAnimation = true;
  Timer? _timer;
  int _duration = 50;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    _timer = Timer(Duration(seconds: _duration), () {
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
    _duration = 0;
    _timer!.cancel();
    animationController?.dispose();
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
        alignment: AlignmentDirectional.topEnd,
        children: [
          WebsiteView(
            initialUrl: initialUrl,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: AnimatedBuilder(
                animation: animationController!,
                builder: (BuildContext context, Widget? child) {
                  return forwardAnimation
                      ? FadeTransition(
                          opacity: fadeAnimation,
                          child: Transform(
                            transform: Matrix4.translationValues(
                              50 * (1.0 - fadeAnimation.value),
                              0,
                              0,
                            ),
                            child: const ClipboardWidget(),
                          ),
                        )
                      : Visibility(
                          visible: showCopyButton,
                          child: ScaleTransition(
                            alignment: Alignment.centerRight,
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
