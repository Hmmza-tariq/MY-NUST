import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynust/Core/internet_manager.dart';
import '../../Components/clipboard_widget.dart';
import '../../Components/webview.dart';

class QalamScreen extends StatefulWidget {
  const QalamScreen({super.key});

  @override
  State<QalamScreen> createState() => _QalamScreenState();
}

class _QalamScreenState extends State<QalamScreen>
    with TickerProviderStateMixin {
  var initialUrl = 'https://qalam.nust.edu.pk/';
  AnimationController? animationController;
  bool showCopyButton = true;
  bool forwardAnimation = true;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    if (!isConnected) {
      showCopyButton = false;
      forwardAnimation = false;
    }

    Timer(const Duration(seconds: 50), () {
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
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
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
                            child: const ClipboardWidget(
                              name: 'Qalam',
                            ),
                          ),
                        )
                      : Visibility(
                          visible: showCopyButton,
                          child: ScaleTransition(
                            scale: scaleAnimation,
                            child: const ClipboardWidget(
                              name: 'Qalam',
                            ),
                          ),
                        );
                }),
          )
        ],
      )),
    );
  }
}
